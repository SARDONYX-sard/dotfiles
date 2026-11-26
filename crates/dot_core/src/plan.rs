//! Compare the manifest against the filesystem and decide what to do per link.
//! Planning never mutates anything; it is what `deploy --dry-run` prints.

use std::fmt;
use std::path::{Path, PathBuf};

use anyhow::Result;

use crate::manifest::Manifest;
use crate::path::expand;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Action {
    /// Already a symlink to the desired source.
    Ok,
    /// Destination does not exist.
    Create,
    /// Symlink into this repo but to another file (old layout) -> swap target.
    Relink { old: PathBuf },
    /// Symlink whose target does not exist.
    Dangling { old: PathBuf },
    /// Real file/dir, or a symlink pointing outside the repo. Needs `--force` (backup first).
    Conflict { reason: String },
    /// Source missing in `dots/`; nothing can be linked.
    MissingSrc,
}

#[derive(Debug)]
pub struct PlanEntry {
    pub pkg: String,
    pub src: PathBuf,
    pub dst: PathBuf,
    pub action: Action,
}

#[derive(Debug, Default)]
pub struct Plan {
    pub entries: Vec<PlanEntry>,
}

impl Plan {
    /// `repo_root` is the dotfiles repo; `dots_dir` is `<repo_root>/dots`.
    pub fn build(manifest: &Manifest, repo_root: &Path, dots_dir: &Path) -> Result<Self> {
        let repo_root = canon(repo_root).unwrap_or_else(|| repo_root.to_path_buf());
        let mut entries = Vec::new();

        for (name, pkg) in &manifest.pkg {
            if !pkg.applies_here() {
                continue;
            }
            for link in &pkg.link {
                let Some(dst_tpl) = link.dst.current() else {
                    continue;
                };
                // `~/...` sources point outside the repo (e.g. `dot gen` output).
                let src = match link.src.to_str().filter(|s| crate::path::is_template(s)) {
                    Some(s) => expand(s)?,
                    None => crate::path::normalize(dots_dir.join(&link.src)),
                };
                let dst = expand(dst_tpl)?;
                let action = classify(&src, &dst, &repo_root);
                entries.push(PlanEntry {
                    pkg: name.clone(),
                    src,
                    dst,
                    action,
                });
            }
        }
        Ok(Self { entries })
    }
}

impl PlanEntry {
    /// A single link outside any manifest (`dot link`).
    pub fn adhoc(src: PathBuf, dst: PathBuf, repo_root: &Path) -> Self {
        let action = classify(&src, &dst, repo_root);
        Self {
            pkg: "link".to_string(),
            src,
            dst,
            action,
        }
    }
}

fn classify(src: &Path, dst: &Path, repo_root: &Path) -> Action {
    let Some(src_canon) = canon(src) else {
        return Action::MissingSrc;
    };

    let Ok(meta) = std::fs::symlink_metadata(dst) else {
        return Action::Create;
    };

    if !meta.file_type().is_symlink() {
        let kind = if meta.is_dir() { "directory" } else { "file" };
        return Action::Conflict {
            reason: format!("real {kind}"),
        };
    }

    let raw = std::fs::read_link(dst).unwrap_or_default();
    let target = if raw.is_relative() {
        dst.parent().map(|p| p.join(&raw)).unwrap_or(raw.clone())
    } else {
        raw.clone()
    };

    match canon(&target) {
        Some(t) if t == src_canon => Action::Ok,
        Some(t) if t.starts_with(repo_root) => Action::Relink { old: raw },
        Some(_) => Action::Conflict {
            reason: format!("symlink outside repo -> {}", raw.display()),
        },
        None => Action::Dangling { old: raw },
    }
}

fn canon(p: &Path) -> Option<PathBuf> {
    std::fs::canonicalize(p).ok()
}

impl fmt::Display for Action {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Action::Ok => f.write_str("ok"),
            Action::Create => f.write_str("create"),
            Action::Relink { old } => write!(f, "relink (was {})", old.display()),
            Action::Dangling { old } => write!(f, "dangling (was {})", old.display()),
            Action::Conflict { reason } => write!(f, "CONFLICT: {reason}"),
            Action::MissingSrc => f.write_str("missing src"),
        }
    }
}

/// Symlinks in common config locations that point into `repo_root` but are not
/// a destination in the plan. These would dangle once the old layout is removed.
pub fn unmanaged_links(plan: &Plan, repo_root: &Path) -> Vec<(PathBuf, PathBuf)> {
    let repo = canon(repo_root).unwrap_or_else(|| repo_root.to_path_buf());
    let managed: std::collections::HashSet<_> =
        plan.entries.iter().map(|e| e.dst.clone()).collect();

    let mut roots: Vec<(PathBuf, usize)> = Vec::new();
    if let Some(h) = dirs::home_dir() {
        roots.push((h.clone(), 1));
        roots.push((h.join(".config"), 2));
    }
    for d in [
        dirs::document_dir(),
        dirs::config_dir(),
        dirs::data_local_dir(),
    ]
    .into_iter()
    .flatten()
    {
        roots.push((d, 2));
    }
    if let Some(l) = dirs::data_local_dir() {
        roots.push((l.join("Packages"), 3)); // Windows Store apps (Windows Terminal, ...)
    }

    let mut found = Vec::new();
    for (root, depth) in roots {
        walk(&root, depth, &mut |path| {
            let Ok(raw) = std::fs::read_link(path) else {
                return;
            };
            let abs = if raw.is_relative() {
                path.parent().map(|p| p.join(&raw)).unwrap_or(raw.clone())
            } else {
                raw.clone()
            };
            // Dangling links cannot be canonicalized: compare lexically, ignoring case
            // (`c:\` vs `C:\`) and the `\\?\` prefix.
            let inside = match canon(&abs) {
                Some(t) => t.starts_with(&repo),
                None => lexical_key(&abs).starts_with(&lexical_key(repo_root)),
            };
            if inside && !managed.contains(path) {
                found.push((path.to_path_buf(), raw));
            }
        });
    }
    found.sort();
    found.dedup();
    found
}

/// Visit entries up to `depth` levels below `dir`, not descending into symlinks.
fn walk(dir: &Path, depth: usize, f: &mut dyn FnMut(&Path)) {
    let Ok(rd) = std::fs::read_dir(dir) else {
        return;
    };
    for e in rd.flatten() {
        let path = e.path();
        let Ok(ft) = e.file_type() else { continue };
        if ft.is_symlink() {
            f(&path);
        } else if ft.is_dir() && depth > 1 {
            walk(&path, depth - 1, f);
        }
    }
}

fn lexical_key(p: &Path) -> String {
    let s = p.to_string_lossy().replace('/', "\\");
    let s = s.strip_prefix(r"\?\").unwrap_or(&s);
    if cfg!(windows) {
        s.to_lowercase()
    } else {
        s.to_string()
    }
}
