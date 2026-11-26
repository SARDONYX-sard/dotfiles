//! Release helpers (`cargo xtask <cmd>`, alias in .cargo/config.toml).
//!
//!   cargo xtask dist [--target <triple>]          build + pack into dist/dot-<target>.*
//!   cargo xtask release <x.y.z> [--dry-run] [--push]
//!       checks (fmt, clippy, test) -> bump version -> commit -> tag [-> push]
//!       Pushing the tag triggers .github/workflows/release.yml.

use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context as _, Result, bail, ensure};

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let flag = |f: &str| args.iter().any(|a| a == f);
    let value = |f: &str| {
        args.iter()
            .position(|a| a == f)
            .and_then(|i| args.get(i + 1))
            .cloned()
    };

    match args.first().map(String::as_str) {
        Some("dist") => dist(value("--target").as_deref()),
        Some("release") => {
            let version = args
                .get(1)
                .filter(|v| !v.starts_with('-'))
                .context("usage: release <x.y.z>")?;
            release(version, flag("--dry-run"), flag("--push"))
        }
        _ => {
            eprintln!(
                "usage:\n  cargo xtask dist [--target <triple>]\n  cargo xtask release <x.y.z> [--dry-run] [--push]"
            );
            std::process::exit(2)
        }
    }
}

fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("xtask is in the workspace root")
        .to_path_buf()
}

/// Run a command in the workspace root, failing on non-zero exit.
fn run(prog: &str, args: &[&str]) -> Result<()> {
    println!("\x1b[32m$ {prog} {}\x1b[0m", args.join(" "));
    let status = Command::new(prog)
        .args(args)
        .current_dir(root())
        .status()
        .with_context(|| format!("failed to run {prog}"))?;
    ensure!(
        status.success(),
        "`{prog} {}` failed ({status})",
        args.join(" ")
    );
    Ok(())
}

fn output(prog: &str, args: &[&str]) -> Result<String> {
    let out = Command::new(prog)
        .args(args)
        .current_dir(root())
        .output()
        .with_context(|| format!("failed to run {prog}"))?;
    ensure!(out.status.success(), "`{prog} {}` failed", args.join(" "));
    Ok(String::from_utf8_lossy(&out.stdout).trim().to_string())
}

fn host_triple() -> Result<String> {
    output("rustc", &["-vV"])?
        .lines()
        .find_map(|l| l.strip_prefix("host: ").map(str::to_string))
        .context("no host in `rustc -vV`")
}

fn workspace_version() -> Result<String> {
    let doc: toml_edit::DocumentMut =
        std::fs::read_to_string(root().join("Cargo.toml"))?.parse()?;
    doc["workspace"]["package"]["version"]
        .as_str()
        .map(str::to_string)
        .context("no [workspace.package] version")
}

/// Build `dot` in release mode and pack it with `dots/`, readme and licenses into
/// `dist/dot-<target>.{zip,tar.gz}`.
fn dist(target: Option<&str>) -> Result<()> {
    let target = match target {
        Some(t) => t.to_string(),
        None => host_triple()?,
    };
    run(
        "cargo",
        &[
            "build",
            "--release",
            "--locked",
            "-p",
            "dot_cli",
            "--target",
            &target,
        ],
    )?;

    let root = root();
    let exe = if target.contains("windows") {
        "dot.exe"
    } else {
        "dot"
    };
    // No version in the name: bootstrap downloads `releases/latest/download/dot-<target>.*`.
    let name = format!("dot-{target}");
    let stage = root.join("dist").join(&name);
    let _ = std::fs::remove_dir_all(&stage);
    std::fs::create_dir_all(&stage)?;
    std::fs::copy(
        root.join("target").join(&target).join("release").join(exe),
        stage.join(exe),
    )?;
    for f in ["readme.md", "LICENSE", "LICENSE-APACHE", "LICENSE-MIT"] {
        std::fs::copy(root.join(f), stage.join(f))?;
    }
    // The configs too: bootstrap installs from this archive alone (no git needed).
    copy_dir(&root.join("dots"), &stage.join("dots"))?;

    // bsdtar (Windows 10+, macOS) and GNU tar both handle these; `-a` picks zip by extension.
    let (archive, flags) = if target.contains("windows") {
        (format!("{name}.zip"), "-acf")
    } else {
        (format!("{name}.tar.gz"), "-czf")
    };
    let dist_dir = root.join("dist");
    let status = Command::new("tar")
        .args([flags, &archive, &name])
        .current_dir(&dist_dir)
        .status()?;
    ensure!(status.success(), "tar failed");
    println!("{}", dist_dir.join(&archive).display());
    Ok(())
}

fn release(version: &str, dry_run: bool, push: bool) -> Result<()> {
    let valid = version.split('-').next().is_some_and(|core| {
        let parts: Vec<_> = core.split('.').collect();
        parts.len() == 3
            && parts
                .iter()
                .all(|p| !p.is_empty() && p.bytes().all(|b| b.is_ascii_digit()))
    });
    ensure!(
        valid,
        "version must look like 1.2.3 or 1.2.3-rc.1, got `{version}`"
    );
    let tag = format!("v{version}");

    if !dry_run {
        ensure!(
            output("git", &["status", "--porcelain"])?.is_empty(),
            "working tree is not clean"
        );
    }
    if !output("git", &["tag", "--list", &tag])?.is_empty() {
        bail!("tag {tag} already exists");
    }

    run("cargo", &["fmt", "--all", "--", "--check"])?;
    run(
        "cargo",
        &[
            "clippy",
            "--workspace",
            "--all-targets",
            "--locked",
            "--",
            "-D",
            "warnings",
        ],
    )?;
    run("cargo", &["test", "--workspace", "--locked"])?;

    let old = workspace_version()?;
    if dry_run {
        println!(
            "dry run: would {}tag {tag}{}",
            if old == version {
                String::new()
            } else {
                format!("bump {old} -> {version}, commit, ")
            },
            if push { ", push" } else { "" }
        );
        return Ok(());
    }

    // Already at this version (e.g. the first release): tag HEAD without a bump commit.
    if old != version {
        let path = root().join("Cargo.toml");
        let mut doc: toml_edit::DocumentMut = std::fs::read_to_string(&path)?.parse()?;
        doc["workspace"]["package"]["version"] = toml_edit::value(version);
        std::fs::write(&path, doc.to_string())?;
        run("cargo", &["update", "--workspace"])?; // refresh Cargo.lock

        run("git", &["add", "Cargo.toml", "Cargo.lock"])?;
        run("git", &["commit", "-m", &format!("chore(release): {tag}")])?;
    }
    run("git", &["tag", "-a", &tag, "-m", &tag])?;
    if push {
        run("git", &["push", "origin", "HEAD", "--follow-tags"])?;
    } else {
        println!("next: git push origin HEAD --follow-tags   (triggers the release workflow)");
    }
    Ok(())
}

fn copy_dir(from: &Path, to: &Path) -> Result<()> {
    std::fs::create_dir_all(to)?;
    for entry in std::fs::read_dir(from)? {
        let entry = entry?;
        let target = to.join(entry.file_name());
        if entry.file_type()?.is_dir() {
            copy_dir(&entry.path(), &target)?;
        } else {
            std::fs::copy(entry.path(), &target)?;
        }
    }
    Ok(())
}
