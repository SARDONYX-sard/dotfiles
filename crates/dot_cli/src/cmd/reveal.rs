//! `dot reveal`: show a file (or a command's binary) selected in the OS file manager.
//!
//! - Windows: `explorer /select,<path>`
//! - WSL:     `explorer.exe /select,<wslpath -w path>`
//! - macOS:   `open -R <path>`
//! - Linux:   D-Bus `org.freedesktop.FileManager1.ShowItems`, else `xdg-open <dir>`
//!
//! Directories are opened rather than selected.

use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use anyhow::{Context as _, Result};

/// With `dry_run`, only print the resolved path.
pub fn run(target: Option<&str>, dry_run: bool) -> Result<()> {
    let path = resolve(target)?;
    if dry_run {
        println!("{}", path.display());
        return Ok(());
    }
    if path.is_dir() {
        open_dir(&path)
    } else {
        select(&path)
    }
}

/// Existing path as given, else a command in PATH (scoop shims resolved).
fn resolve(target: Option<&str>) -> Result<PathBuf> {
    let Some(t) = target else {
        return Ok(std::env::current_dir()?);
    };
    let p = Path::new(t);
    if p.exists() {
        return Ok(dot_core::path::canonical(p));
    }
    let exe = which::which(t)
        .with_context(|| format!("`{t}` is neither a path nor a command in PATH"))?;
    Ok(crate::cmd::which::resolve_shim(&exe).unwrap_or(exe))
}

#[cfg(not(windows))]
fn is_wsl() -> bool {
    cfg!(target_os = "linux") && std::env::var_os("WSL_DISTRO_NAME").is_some()
}

fn spawn(cmd: &mut Command) -> Result<()> {
    // explorer.exe exits with 1 even on success, so the status is not checked.
    cmd.stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .with_context(|| format!("failed to run {cmd:?}"))?;
    Ok(())
}

#[cfg(windows)]
fn select(path: &Path) -> Result<()> {
    use std::os::windows::process::CommandExt as _;
    // explorer parses its command line itself: pass `/select,"<path>"` verbatim.
    spawn(Command::new("explorer.exe").raw_arg(format!("/select,\"{}\"", path.display())))
}

#[cfg(windows)]
fn open_dir(path: &Path) -> Result<()> {
    spawn(Command::new("explorer.exe").arg(path))
}

#[cfg(not(windows))]
fn select(path: &Path) -> Result<()> {
    if is_wsl() {
        return spawn(Command::new("explorer.exe").arg(format!("/select,{}", wslpath(path)?)));
    }
    if cfg!(target_os = "macos") {
        return spawn(Command::new("open").arg("-R").arg(path));
    }
    // freedesktop file managers (Nautilus, Dolphin, Thunar, ...).
    let uri = format!("file://{}", path.display());
    let ok = Command::new("dbus-send")
        .args([
            "--session",
            "--print-reply",
            "--dest=org.freedesktop.FileManager1",
            "/org/freedesktop/FileManager1",
            "org.freedesktop.FileManager1.ShowItems",
        ])
        .arg(format!("array:string:{uri}"))
        .arg("string:")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok_and(|s| s.success());
    if ok {
        return Ok(());
    }
    open_dir(path.parent().unwrap_or(path))
}

#[cfg(not(windows))]
fn open_dir(path: &Path) -> Result<()> {
    if is_wsl() {
        return spawn(Command::new("explorer.exe").arg(wslpath(path)?));
    }
    let opener = if cfg!(target_os = "macos") {
        "open"
    } else {
        "xdg-open"
    };
    spawn(Command::new(opener).arg(path))
}

/// Linux path -> Windows path (`/mnt/c/x` -> `C:\x`, `/home/u` -> `\\wsl.localhost\...`).
#[cfg(not(windows))]
fn wslpath(path: &Path) -> Result<String> {
    let out = Command::new("wslpath")
        .arg("-w")
        .arg(path)
        .output()
        .context("wslpath not found")?;
    if !out.status.success() {
        anyhow::bail!("wslpath failed for {}", path.display());
    }
    Ok(String::from_utf8_lossy(&out.stdout).trim().to_string())
}
