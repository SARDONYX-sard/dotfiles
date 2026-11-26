//! Rust segment: shown only inside a Cargo project.
//!
//! Version source, in order:
//! 1. `rust-toolchain.toml` / `rust-toolchain` `channel` in an ancestor dir
//! 2. `rustc -V`, cached in `~/.cache/dot/rustc-version` and invalidated when
//!    rustup's `settings.toml` (default toolchain) changes.

use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::SystemTime;

pub fn toolchain(cwd: &Path) -> Option<String> {
    let project = cwd.ancestors().find(|d| d.join("Cargo.toml").is_file())?;
    for dir in project.ancestors() {
        if let Some(ch) = read_channel(&dir.join("rust-toolchain.toml"))
            .or_else(|| read_channel(&dir.join("rust-toolchain")))
        {
            return Some(ch);
        }
    }
    cached_rustc_version()
}

fn read_channel(path: &Path) -> Option<String> {
    let text = std::fs::read_to_string(path).ok()?;
    // Legacy `rust-toolchain` may be just the channel name.
    if !text.contains('=') {
        return Some(text.trim().to_string()).filter(|s| !s.is_empty());
    }
    text.lines().find_map(|l| {
        let v = l
            .trim()
            .strip_prefix("channel")?
            .trim_start()
            .strip_prefix('=')?;
        Some(v.trim().trim_matches('"').to_string())
    })
}

fn cached_rustc_version() -> Option<String> {
    let home = dirs::home_dir()?;
    let cache = home.join(".cache").join("dot").join("rustc-version");
    let key = mtime_key(&rustup_settings(&home));

    if let Ok(text) = std::fs::read_to_string(&cache)
        && let Some((k, v)) = text.split_once('\n')
        && k == key
    {
        return Some(v.trim().to_string());
    }

    let out = Command::new("rustc").arg("-V").output().ok()?;
    // "rustc 1.100.0 (0ef1bc386 2026-11-09)"
    let ver = String::from_utf8_lossy(&out.stdout)
        .split_whitespace()
        .nth(1)?
        .to_string();
    if let Some(dir) = cache.parent() {
        let _ = std::fs::create_dir_all(dir);
        let _ = std::fs::write(&cache, format!("{key}\n{ver}"));
    }
    Some(ver)
}

fn rustup_settings(home: &Path) -> PathBuf {
    std::env::var_os("RUSTUP_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| home.join(".rustup"))
        .join("settings.toml")
}

fn mtime_key(path: &Path) -> String {
    std::fs::metadata(path)
        .and_then(|m| m.modified())
        .ok()
        .and_then(|t| t.duration_since(SystemTime::UNIX_EPOCH).ok())
        .map_or_else(|| "none".into(), |d| d.as_nanos().to_string())
}
