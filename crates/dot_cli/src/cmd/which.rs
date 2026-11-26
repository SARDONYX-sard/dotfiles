//! `dot which`: locate executables in PATH, resolving scoop shims to the real binary.

use std::path::{Path, PathBuf};

use anyhow::{Result, bail};

pub fn run(name: &str, all: bool) -> Result<()> {
    // PATH often lists the same dir twice (or via 8.3 short names); dedupe by real path.
    let mut seen = std::collections::HashSet::new();
    let found: Vec<PathBuf> = which::which_all(name)?
        .filter(|p| seen.insert(std::fs::canonicalize(p).unwrap_or_else(|_| p.clone())))
        .collect();
    if found.is_empty() {
        bail!("{name}: not found");
    }
    for p in found.iter().take(if all { usize::MAX } else { 1 }) {
        match resolve_shim(p) {
            Some(real) => println!("{}  (shim: {})", real.display(), p.display()),
            None => println!("{}", p.display()),
        }
    }
    Ok(())
}

/// scoop places `<name>.shim` next to `<name>.exe` with a `path = "..."` line.
pub fn resolve_shim(exe: &Path) -> Option<PathBuf> {
    let text = std::fs::read_to_string(exe.with_extension("shim")).ok()?;
    text.lines().find_map(|l| {
        let v = l
            .trim()
            .strip_prefix("path")?
            .trim_start()
            .strip_prefix('=')?;
        Some(PathBuf::from(v.trim().trim_matches('"')))
    })
}
