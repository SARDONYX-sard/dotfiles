//! Execute a [`Plan`] and undo it.
//!
//! Every change is recorded before the next one starts, so a failure midway
//! still leaves a transaction that `rollback` can undo.

use std::path::{Path, PathBuf};
use std::time::SystemTime;

use anyhow::{Context as _, Result, bail};

use crate::fsx;
use crate::plan::{Action, Plan};
use crate::state::{Before, Op, State, Transaction};

pub struct Options {
    /// Replace conflicting real files (moved to `backup_dir`).
    pub force: bool,
    /// Unmanaged symlinks to remove (see [`crate::plan::unmanaged_links`]).
    pub prune: Vec<PathBuf>,
    pub state_path: PathBuf,
    pub backup_dir: PathBuf,
}

impl Options {
    pub fn default_paths(force: bool) -> Result<Self> {
        let state_path = State::default_path()?;
        let backup_dir = state_path.with_file_name("backup");
        Ok(Self {
            force,
            prune: Vec::new(),
            state_path,
            backup_dir,
        })
    }
}

#[derive(Debug, Default)]
pub struct Report {
    pub changed: Vec<PathBuf>,
    /// Script that undoes this deploy without `dot` (written next to backups).
    pub restore_script: Option<PathBuf>,
    pub skipped: Vec<(PathBuf, String)>,
}

pub fn apply(plan: &Plan, opts: &Options) -> Result<Report> {
    let mut state = State::load(&opts.state_path)?;
    let now = unix_now();
    // Unique per deploy, even for two deploys within the same second.
    let tx_dir = unique_dir(&opts.backup_dir, now);
    state.transactions.push(Transaction {
        time: now,
        ops: Vec::new(),
    });
    let mut report = Report::default();

    let result = (|| -> Result<()> {
        for e in &plan.entries {
            let before = match &e.action {
                Action::Ok => continue,
                Action::MissingSrc => {
                    report.skipped.push((e.dst.clone(), "missing src".into()));
                    continue;
                }
                Action::Conflict { reason } if !opts.force => {
                    report
                        .skipped
                        .push((e.dst.clone(), format!("conflict: {reason} (use --force)")));
                    continue;
                }
                Action::Create => Before::Missing,
                Action::Relink { old } | Action::Dangling { old } => {
                    let dir = fsx::is_dir_link(&e.dst);
                    fsx::remove_symlink(&e.dst)
                        .with_context(|| format!("remove {}", e.dst.display()))?;
                    Before::Link {
                        target: old.clone(),
                        dir,
                    }
                }
                Action::Conflict { .. } => {
                    let backup = backup_path(&tx_dir, &e.dst);
                    if let Some(d) = backup.parent() {
                        std::fs::create_dir_all(d)?;
                    }
                    move_path(&e.dst, &backup)?;
                    Before::Backup { path: backup }
                }
            };

            // Record first: if linking fails, rollback can still restore `before`.
            let op = Op {
                dst: e.dst.clone(),
                src: Some(e.src.clone()),
                before,
            };
            state
                .transactions
                .last_mut()
                .expect("pushed above")
                .ops
                .push(op);
            state.save(&opts.state_path)?;

            if let Some(parent) = e.dst.parent() {
                std::fs::create_dir_all(parent)
                    .with_context(|| format!("mkdir {}", parent.display()))?;
            }
            fsx::symlink(&e.src, &e.dst, e.src.is_dir())
                .with_context(|| format!("link {} -> {}", e.dst.display(), e.src.display()))?;
            report.changed.push(e.dst.clone());
        }

        for dst in &opts.prune {
            let Ok(target) = std::fs::read_link(dst) else {
                continue;
            };
            let before = Before::Link {
                target,
                dir: fsx::is_dir_link(dst),
            };
            state
                .transactions
                .last_mut()
                .expect("pushed above")
                .ops
                .push(Op {
                    dst: dst.clone(),
                    src: None,
                    before,
                });
            state.save(&opts.state_path)?;
            fsx::remove_symlink(dst).with_context(|| format!("remove {}", dst.display()))?;
            report.changed.push(dst.clone());
        }
        Ok(())
    })();

    if state.transactions.last().is_some_and(|t| t.ops.is_empty()) {
        state.transactions.pop();
    } else if let Some(tx) = state.transactions.last() {
        // Plain script that undoes this deploy even if `dot` itself is broken.
        std::fs::create_dir_all(&tx_dir)?;
        let (name, text) = restore_script(tx);
        let path = tx_dir.join(name);
        std::fs::write(&path, text)?;
        report.restore_script = Some(path);
    }
    state.save(&opts.state_path)?;
    result.map(|()| report)
}

/// Shell script equivalent of `rollback` for one transaction.
fn restore_script(tx: &Transaction) -> (&'static str, String) {
    let mut s = String::new();
    if cfg!(windows) {
        let q = |p: &Path| format!("'{}'", p.display().to_string().replace('\'', "''"));
        s.push_str(concat!(
            "# Undo `dot deploy` without `dot`: pwsh -File restore.ps1\n",
            "$ErrorActionPreference = 'Stop'\n",
            "function Remove-Link($p) {\n",
            "  $i = Get-Item -LiteralPath $p -Force -ErrorAction Ignore\n",
            "  if (-not $i) { return }\n",
            "  if (-not $i.LinkType) { throw \"$p is not a link; refusing to delete\" }\n",
            "  if ($i.PSIsContainer) { [IO.Directory]::Delete($p) } else { [IO.File]::Delete($p) }\n",
            "}\n",
        ));
        for op in tx.ops.iter().rev() {
            let dst = q(&op.dst);
            s += &format!("Remove-Link {dst}\n");
            match &op.before {
                Before::Missing => {}
                Before::Link { target, .. } => {
                    s += &format!(
                        "New-Item -ItemType SymbolicLink -Path {dst} -Target {} | Out-Null\n",
                        q(target)
                    );
                }
                Before::Backup { path } => {
                    s += &format!("Move-Item -LiteralPath {} -Destination {dst}\n", q(path))
                }
            }
        }
        ("restore.ps1", s)
    } else {
        let q = |p: &Path| format!("'{}'", p.display().to_string().replace('\'', r"'\''"));
        s.push_str("#!/bin/sh\n# Undo `dot deploy` without `dot`.\nset -eu\n");
        for op in tx.ops.iter().rev() {
            let dst = q(&op.dst);
            s += &format!("if [ -L {dst} ]; then rm {dst}; fi\n");
            match &op.before {
                Before::Missing => {}
                Before::Link { target, .. } => s += &format!("ln -s {} {dst}\n", q(target)),
                Before::Backup { path } => s += &format!("mv {} {dst}\n", q(path)),
            }
        }
        ("restore.sh", s)
    }
}

/// Undo the most recent deploy. Returns the restored destinations.
pub fn rollback(opts: &Options, dry_run: bool) -> Result<Vec<String>> {
    let mut state = State::load(&opts.state_path)?;
    let Some(tx) = state.transactions.last() else {
        bail!("nothing to roll back");
    };

    let mut log = Vec::new();
    for op in tx.ops.iter().rev() {
        // Only touch what we created/removed; leave anything the user changed since.
        let exists = std::fs::symlink_metadata(&op.dst).is_ok();
        let ours = match &op.src {
            Some(src) => std::fs::read_link(&op.dst).is_ok_and(|t| &t == src),
            None => !exists,
        };
        if exists && !ours {
            log.push(format!("skip {} (changed since deploy)", op.dst.display()));
            continue;
        }
        let what = match &op.before {
            Before::Missing => "remove".to_string(),
            Before::Link { target, .. } => format!("relink -> {}", target.display()),
            Before::Backup { path } => format!("restore from {}", path.display()),
        };
        log.push(format!("{} : {what}", op.dst.display()));
        if dry_run {
            continue;
        }
        if exists {
            fsx::remove_symlink(&op.dst)?;
        }
        match &op.before {
            Before::Missing => {}
            Before::Link { target, dir } => fsx::symlink(target, &op.dst, *dir)?,
            Before::Backup { path } => move_path(path, &op.dst)?,
        }
    }

    if !dry_run {
        state.transactions.pop();
        state.save(&opts.state_path)?;
    }
    Ok(log)
}

fn unix_now() -> u64 {
    SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .map_or(0, |d| d.as_secs())
}

/// `<backup_dir>/<time>[-n]`, not yet existing.
fn unique_dir(backup_dir: &Path, time: u64) -> PathBuf {
    let mut dir = backup_dir.join(time.to_string());
    let mut n = 1;
    while dir.exists() {
        dir = backup_dir.join(format!("{time}-{n}"));
        n += 1;
    }
    dir
}

/// `<tx_dir>/<dst without root, e.g. C/Users/me/.gitconfig>`
fn backup_path(tx_dir: &Path, dst: &Path) -> PathBuf {
    use std::path::Component;
    let rel: PathBuf = dst
        .components()
        .filter_map(|c| match c {
            Component::Prefix(p) => Some(
                p.as_os_str()
                    .to_string_lossy()
                    .replace([':', '\\', '?', '.'], "")
                    .into(),
            ),
            Component::Normal(s) => Some(s.to_owned()),
            _ => None,
        })
        .collect();
    tx_dir.join(rel)
}

/// Rename, falling back to copy+delete across volumes (e.g. C: -> D:).
fn move_path(from: &Path, to: &Path) -> Result<()> {
    if std::fs::rename(from, to).is_ok() {
        return Ok(());
    }
    if from.is_dir() {
        bail!(
            "cannot move directory {} across volumes; move it manually",
            from.display()
        );
    }
    std::fs::copy(from, to)
        .with_context(|| format!("copy {} -> {}", from.display(), to.display()))?;
    std::fs::remove_file(from).with_context(|| format!("remove {}", from.display()))
}
