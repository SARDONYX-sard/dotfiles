//! Destination path template expansion.
//!
//! Supported tokens:
//! - leading `~`        : home directory
//! - `{documents}`      : Known Folder "Documents" (may be relocated, e.g. `D:\ドキュメント`)
//! - `{appdata}`        : Roaming AppData (Windows) / `~/.config` (unix)
//! - `{localappdata}`   : Local AppData (Windows) / `~/.local/share` (unix)

use std::path::PathBuf;

use anyhow::{Context as _, Result, bail};

pub fn expand(template: &str) -> Result<PathBuf> {
    let mut s = template.to_owned();

    if let Some(rest) = s.strip_prefix('~') {
        let home = dirs::home_dir().context("home directory not found")?;
        s = format!("{}{rest}", home.display());
    }

    for (token, dir) in [
        ("{documents}", dirs::document_dir()),
        ("{appdata}", dirs::config_dir()),
        ("{localappdata}", dirs::data_local_dir()),
    ] {
        if s.contains(token) {
            let dir = dir.with_context(|| format!("cannot resolve {token}"))?;
            s = s.replace(token, &dir.display().to_string());
        }
    }

    if let Some(start) = s.find('{') {
        bail!("unknown token in `{template}` at byte {start}");
    }

    Ok(normalize(PathBuf::from(s)))
}

/// Whether `s` is an absolute template (`~/...` or `{token}/...`) rather than a
/// path relative to a layer root.
pub fn is_template(s: &str) -> bool {
    s.starts_with('~') || s.starts_with('{')
}

/// Rebuild from components so `/` written in templates becomes the native separator.
pub fn normalize(p: impl AsRef<std::path::Path>) -> PathBuf {
    p.as_ref().components().collect()
}

/// `canonicalize` without Windows' `\\?\` prefix (falls back to the input).
pub fn canonical(p: &std::path::Path) -> PathBuf {
    let Ok(c) = std::fs::canonicalize(p) else {
        return p.to_path_buf();
    };
    let s = c.to_string_lossy();
    match s
        .strip_prefix(r"\\?\")
        .filter(|rest| !rest.starts_with(r"UNC\"))
    {
        Some(rest) => PathBuf::from(rest),
        None => c,
    }
}

/// Whether a command (looked up in PATH) or a path (`~` allowed, contains a slash)
/// exists. Used by `requires` conditions.
pub fn requirement_met(req: &str) -> bool {
    if req.contains(['/', '\\']) {
        expand(req).is_ok_and(|p| p.exists())
    } else {
        which::which(req).is_ok()
    }
}
