//! `dot tolf`: convert CRLF to LF in text files, in parallel.
//!
//! Respects .gitignore / .ignore, skips `.git` and hidden files (unless `--hidden`),
//! and skips binary files (NUL byte in the first 8 KiB).

use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicUsize, Ordering};

use anyhow::Result;
use rayon::prelude::*;

pub struct Opts {
    pub paths: Vec<PathBuf>,
    /// Only files with these extensions (without dot). Empty = all.
    pub ext: Vec<String>,
    pub hidden: bool,
    pub dry_run: bool,
}

pub fn run(opts: &Opts) -> Result<()> {
    let roots: Vec<&Path> = if opts.paths.is_empty() {
        vec![Path::new(".")]
    } else {
        opts.paths.iter().map(PathBuf::as_path).collect()
    };

    let mut walk = ignore::WalkBuilder::new(roots[0]);
    for r in &roots[1..] {
        walk.add(r);
    }
    walk.hidden(!opts.hidden);

    let files: Vec<PathBuf> = walk
        .build()
        .filter_map(Result::ok)
        .filter(|e| e.file_type().is_some_and(|t| t.is_file()))
        .map(ignore::DirEntry::into_path)
        .filter(|p| {
            opts.ext.is_empty()
                || p.extension()
                    .is_some_and(|e| opts.ext.iter().any(|x| e == x.as_str()))
        })
        .collect();

    let changed = AtomicUsize::new(0);
    files
        .par_iter()
        .for_each(|path| match convert(path, opts.dry_run) {
            Ok(true) => {
                changed.fetch_add(1, Ordering::Relaxed);
                println!("{}", path.display());
            }
            Ok(false) => {}
            Err(e) => eprintln!("error: {}: {e}", path.display()),
        });

    let n = changed.into_inner();
    let verb = if opts.dry_run {
        "would convert"
    } else {
        "converted"
    };
    eprintln!("{verb} {n} / {} files", files.len());
    Ok(())
}

/// Returns whether the file contains CRLF (and was rewritten unless `dry_run`).
fn convert(path: &Path, dry_run: bool) -> std::io::Result<bool> {
    let bytes = std::fs::read(path)?;
    if bytes[..bytes.len().min(8192)].contains(&0) || !bytes.windows(2).any(|w| w == b"\r\n") {
        return Ok(false);
    }
    if !dry_run {
        let mut out = Vec::with_capacity(bytes.len());
        let mut it = bytes.iter().peekable();
        while let Some(&b) = it.next() {
            if b == b'\r' && it.peek() == Some(&&b'\n') {
                continue;
            }
            out.push(b);
        }
        std::fs::write(path, out)?;
    }
    Ok(true)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn converts_crlf_only() {
        let dir = std::env::temp_dir().join(format!("dot-tolf-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let text = dir.join("a.txt");
        let bin = dir.join("b.bin");
        std::fs::write(&text, b"a\r\nb\rc\n").unwrap();
        std::fs::write(&bin, b"\0\r\n").unwrap();

        assert!(convert(&text, false).unwrap());
        assert_eq!(std::fs::read(&text).unwrap(), b"a\nb\rc\n");
        assert!(!convert(&text, false).unwrap());
        assert!(!convert(&bin, false).unwrap());
        std::fs::remove_dir_all(dir).unwrap();
    }
}
