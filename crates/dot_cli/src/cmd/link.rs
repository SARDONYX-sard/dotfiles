//! `dot link <src> <dst> [--force]`: `ln -s` for every OS, undoable with `dot rollback`.
//!
//! Paths may be relative (to the current directory) or templates (`~/...`,
//! `{appdata}/...`). On Windows the link kind (file/dir) follows `src`.

use std::path::{Path, PathBuf};

use anyhow::{Result, bail};
use dot_core::apply::{self, Options};
use dot_core::{Action, Plan, PlanEntry};

pub fn run(src: &str, dst: &str, force: bool, dry_run: bool) -> Result<()> {
    let src = resolve(src)?;
    let dst = resolve(dst)?;
    // Only used to tell "old link into this repo" from "foreign link"; any value works.
    let repo = std::env::var_os("DOT_ROOT")
        .map(PathBuf::from)
        .unwrap_or_default();
    let entry = PlanEntry::adhoc(src, dst, &repo);

    println!(
        "{} -> {}\n    {}",
        entry.dst.display(),
        entry.src.display(),
        entry.action
    );
    match &entry.action {
        Action::Ok => return Ok(()),
        Action::MissingSrc => bail!("source does not exist: {}", entry.src.display()),
        Action::Create => {}
        _ if !force => bail!(
            "{} already exists (use --force to replace it)",
            entry.dst.display()
        ),
        _ => {}
    }
    if dry_run {
        return Ok(());
    }

    let opts = Options::default_paths(true)?; // existing real files are backed up first
    let report = apply::apply(
        &Plan {
            entries: vec![entry],
        },
        &opts,
    )?;
    if let Some(p) = &report.restore_script {
        println!("restore script (if `dot` is unavailable): {}", p.display());
    }
    println!("linked (undo: dot rollback)");
    Ok(())
}

fn resolve(p: &str) -> Result<PathBuf> {
    if dot_core::path::is_template(p) {
        return dot_core::path::expand(p);
    }
    let path = Path::new(p);
    Ok(dot_core::path::normalize(if path.is_absolute() {
        path.to_path_buf()
    } else {
        std::env::current_dir()?.join(path)
    }))
}
