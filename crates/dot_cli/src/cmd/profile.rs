//! `dot profile`: list / use / show / new / export / import profiles
//! (`dots/profiles/<name>/`, see `dot_core::profile`).

use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context as _, Result, bail, ensure};
use dot_core::profile::{self, profile_dir};

/// `dot profile list`: `*` marks the active profile.
pub fn list(dots: &Path, active: Option<&str>) -> Result<()> {
    let names = profile::list(dots)?;
    if names.is_empty() {
        println!("no profiles (create one: dot profile new <name>)");
    }
    for name in names {
        let meta = profile::read_meta(dots, &name)?;
        let mark = if active == Some(name.as_str()) {
            "*"
        } else {
            " "
        };
        let extends = if meta.extends.is_empty() {
            String::new()
        } else {
            format!(" (extends {})", meta.extends.join(", "))
        };
        println!(
            "{mark} {name}{extends}  {}",
            meta.description.unwrap_or_default()
        );
    }
    Ok(())
}

/// `dot profile show`: active profile and the resolved layer chain.
pub fn show(dots: &Path, active: Option<&str>) -> Result<()> {
    let Some(name) = active else {
        println!("no active profile (base config only)");
        return Ok(());
    };
    println!("active: {name}");
    println!(
        "layers: core -> {}",
        profile::chain(dots, name)?.join(" -> ")
    );
    Ok(())
}

/// `dot profile use <name>` (validated) or `--clear`.
pub fn use_profile(dots: &Path, name: Option<&str>) -> Result<()> {
    if let Some(n) = name {
        profile::chain(dots, n)?; // exists, no cycles, parents present
    }
    profile::save(name)?;
    match name {
        Some(n) => println!("active profile: {n} (run `dot gen` and `dot deploy -n`)"),
        None => println!("profile cleared (base config only)"),
    }
    Ok(())
}

/// `dot profile new <name>`: scaffold an empty profile.
pub fn new(dots: &Path, name: &str, extends: &[String], description: Option<&str>) -> Result<()> {
    validate_name(name)?;
    let dir = profile_dir(dots, name);
    ensure!(!dir.exists(), "profile `{name}` already exists");
    for parent in extends {
        profile::read_meta(dots, parent)?;
    }
    std::fs::create_dir_all(dir.join("shell"))?;
    let mut meta = String::from("#:schema ../../schemas/profile.schema.json\n");
    if let Some(d) = description {
        meta += &format!("description = {}\n", toml_str(d));
    }
    if !extends.is_empty() {
        let list = extends
            .iter()
            .map(|e| toml_str(e))
            .collect::<Vec<_>>()
            .join(", ");
        meta += &format!("extends = [{list}]\n");
    }
    std::fs::write(dir.join("profile.toml"), meta)?;
    let header = |schema: &str, what: &str| {
        format!("#:schema {schema}\n# Merged over {what} (tables merge, values replace).\n")
    };
    std::fs::write(
        dir.join("dot.toml"),
        header(
            "../../schemas/dot.schema.json",
            "dots/core/dot.toml; `src` is relative to this profile",
        ),
    )?;
    std::fs::write(
        dir.join("tools.toml"),
        header("../../schemas/tools.schema.json", "dots/core/tools.toml"),
    )?;
    std::fs::write(
        dir.join("shell").join("shared.toml"),
        header(
            "../../../schemas/shared.schema.json",
            "dots/core/shell/shared.toml",
        ),
    )?;
    println!("created {}", dir.display());
    Ok(())
}

/// `dot profile export <name> [-o file]`: `<name>.tar.gz` of the profile directory.
pub fn export(dots: &Path, name: &str, out: Option<&Path>) -> Result<()> {
    profile::read_meta(dots, name)?;
    let out = match out {
        Some(p) => absolute(p)?,
        None => std::env::current_dir()?.join(format!("{name}.tar.gz")),
    };
    let status = Command::new("tar")
        .arg("-czf")
        .arg(&out)
        .arg("-C")
        .arg(profile::profiles_dir(dots))
        .arg(name)
        .status()
        .context("failed to run tar")?;
    ensure!(status.success(), "tar failed");
    let meta = profile::read_meta(dots, name)?;
    println!("exported {}", out.display());
    if !meta.extends.is_empty() {
        println!(
            "note: it extends {}; export those too if the receiver lacks them",
            meta.extends.join(", ")
        );
    }
    Ok(())
}

/// `dot profile import <src> [--as name] [--force]`.
///
/// `src`: a profile directory, a `.tar.gz`/`.tgz`/`.zip` from `export`, or a git
/// repository URL with `#<name>` (takes `dots/profiles/<name>` from it).
pub fn import(dots: &Path, src: &str, as_name: Option<&str>, force: bool) -> Result<()> {
    let tmp = std::env::temp_dir().join(format!("dot-import-{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&tmp);
    std::fs::create_dir_all(&tmp)?;
    let result = (|| -> Result<String> {
        let (dir, default_name) = fetch(src, &tmp)?;
        let name = as_name.map(str::to_string).unwrap_or(default_name);
        validate_name(&name)?;
        let dest = profile_dir(dots, &name);
        if dest.exists() {
            ensure!(
                force,
                "profile `{name}` already exists (use --force to replace)"
            );
            std::fs::remove_dir_all(&dest)?;
        }
        copy_dir(&dir, &dest)?;
        Ok(name)
    })();
    let _ = std::fs::remove_dir_all(&tmp);
    let name = result?;

    println!(
        "imported profile `{name}` -> {}",
        profile_dir(dots, &name).display()
    );
    let missing: Vec<_> = profile::read_meta(dots, &name)?
        .extends
        .into_iter()
        .filter(|p| !profile_dir(dots, p).is_dir())
        .collect();
    if !missing.is_empty() {
        println!(
            "warning: missing parent profiles: {} (import them too)",
            missing.join(", ")
        );
    }
    Ok(())
}

/// Resolve `src` into a local profile directory and a default name.
fn fetch(src: &str, tmp: &Path) -> Result<(PathBuf, String)> {
    let path = Path::new(src);
    if path.is_dir() {
        return Ok((path.to_path_buf(), file_name(path)?));
    }
    if path.is_file() {
        let status = Command::new("tar")
            .arg("-xf")
            .arg(path)
            .arg("-C")
            .arg(tmp)
            .status()
            .context("failed to run tar")?;
        ensure!(status.success(), "failed to extract {src}");
        let dirs: Vec<PathBuf> = std::fs::read_dir(tmp)?
            .flatten()
            .map(|e| e.path())
            .filter(|p| p.is_dir())
            .collect();
        let [dir] = dirs.as_slice() else {
            bail!("{src}: expected exactly one profile directory inside")
        };
        return Ok((dir.clone(), file_name(dir)?));
    }
    // git URL: <url>#<profile name>
    let (url, name) = src
        .split_once('#')
        .context("not a directory or archive; for a git repository use <url>#<profile>")?;
    let clone = tmp.join("repo");
    let status = Command::new("git")
        .args(["clone", "--depth", "1", "--quiet", url])
        .arg(&clone)
        .status()
        .context("failed to run git")?;
    ensure!(status.success(), "git clone {url} failed");
    let dir = profile_dir(&clone.join("dots"), name);
    ensure!(dir.is_dir(), "{url} has no dots/profiles/{name}");
    Ok((dir, name.to_string()))
}

fn copy_dir(from: &Path, to: &Path) -> Result<()> {
    std::fs::create_dir_all(to)?;
    for entry in std::fs::read_dir(from)? {
        let entry = entry?;
        let target = to.join(entry.file_name());
        if entry.file_type()?.is_dir() {
            copy_dir(&entry.path(), &target)?;
        } else {
            std::fs::copy(entry.path(), &target)
                .with_context(|| format!("copy {}", entry.path().display()))?;
        }
    }
    Ok(())
}

fn file_name(p: &Path) -> Result<String> {
    Ok(p.file_name()
        .context("no directory name")?
        .to_string_lossy()
        .into_owned())
}

fn absolute(p: &Path) -> Result<PathBuf> {
    Ok(if p.is_absolute() {
        p.to_path_buf()
    } else {
        std::env::current_dir()?.join(p)
    })
}

fn validate_name(name: &str) -> Result<()> {
    let ok = !name.is_empty()
        && name
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '_' || c == '-');
    ensure!(
        ok,
        "invalid profile name `{name}` (use letters, digits, `_`, `-`)"
    );
    Ok(())
}

fn toml_str(s: &str) -> String {
    toml::Value::String(s.to_string()).to_string()
}
