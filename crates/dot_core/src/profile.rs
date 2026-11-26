//! Layers: `dots/core/` (base) and profiles in `dots/profiles/<name>/` (inheritable).
//! Both have the same shape; paths inside are relative to their own root.
//!
//! ```text
//! dots/core/ | dots/profiles/<name>/
//! ├─ profile.toml          (profiles only) extends = ["<parent>", ...], description
//! ├─ dot.toml              links (`src` relative to this root)
//! ├─ tools.toml            dot install / upgrade / clean
//! ├─ shell/shared.toml     dot gen
//! └─ home/ shell/ ...      files referenced by `src`
//! ```
//!
//! Layer order for each config: core -> ancestors (parents first) -> active profile.
//! Later layers win.
//!
//! The active profile is per machine: `--profile` / `$DOT_PROFILE`, else the name
//! saved by `dot profile use` in `~/.local/state/dot/profile`.

use std::path::{Path, PathBuf};

use anyhow::{Context as _, Result, bail};
use schemars::JsonSchema;
use serde::Deserialize;

use crate::config::Layer;

/// `profile.toml`.
#[derive(Debug, Default, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct ProfileMeta {
    /// One-line description shown by `dot profile list`.
    pub description: Option<String>,
    /// Profiles to inherit from, applied in order before this one.
    #[serde(default)]
    pub extends: Vec<String>,
}

pub fn profiles_dir(dots: &Path) -> PathBuf {
    dots.join("profiles")
}

pub fn profile_dir(dots: &Path, name: &str) -> PathBuf {
    profiles_dir(dots).join(name)
}

pub fn read_meta(dots: &Path, name: &str) -> Result<ProfileMeta> {
    let dir = profile_dir(dots, name);
    if !dir.is_dir() {
        bail!("profile `{name}` not found ({})", dir.display());
    }
    let path = dir.join("profile.toml");
    match std::fs::read_to_string(&path) {
        Ok(text) => {
            toml::from_str(&text).with_context(|| format!("failed to parse {}", path.display()))
        }
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(ProfileMeta::default()),
        Err(e) => Err(e).with_context(|| format!("failed to read {}", path.display())),
    }
}

/// Names of all profiles (directories under `dots/profiles`), sorted.
pub fn list(dots: &Path) -> Result<Vec<String>> {
    let Ok(rd) = std::fs::read_dir(profiles_dir(dots)) else {
        return Ok(Vec::new());
    };
    let mut names: Vec<String> = rd
        .flatten()
        .filter(|e| e.path().is_dir())
        .map(|e| e.file_name().to_string_lossy().into_owned())
        .collect();
    names.sort();
    Ok(names)
}

/// `name` and its ancestors, parents first, each once. Errors on cycles/missing.
pub fn chain(dots: &Path, name: &str) -> Result<Vec<String>> {
    fn visit(
        dots: &Path,
        name: &str,
        stack: &mut Vec<String>,
        out: &mut Vec<String>,
    ) -> Result<()> {
        if out.iter().any(|n| n == name) {
            return Ok(());
        }
        if stack.iter().any(|n| n == name) {
            bail!(
                "profile inheritance cycle: {} -> {name}",
                stack.join(" -> ")
            );
        }
        stack.push(name.to_string());
        for parent in read_meta(dots, name)?.extends {
            visit(dots, &parent, stack, out)?;
        }
        stack.pop();
        out.push(name.to_string());
        Ok(())
    }
    let mut out = Vec::new();
    visit(dots, name, &mut Vec::new(), &mut out)?;
    Ok(out)
}

/// `~/.local/state/dot/profile`.
fn state_file() -> Result<PathBuf> {
    let home = dirs::home_dir().context("home directory not found")?;
    Ok(home
        .join(".local")
        .join("state")
        .join("dot")
        .join("profile"))
}

/// Profile saved by `dot profile use`, if any.
pub fn saved() -> Option<String> {
    let text = std::fs::read_to_string(state_file().ok()?).ok()?;
    Some(text.trim().to_string()).filter(|s| !s.is_empty())
}

/// Save (or with `None`, clear) the active profile for this machine.
pub fn save(name: Option<&str>) -> Result<()> {
    let path = state_file()?;
    match name {
        Some(n) => {
            if let Some(dir) = path.parent() {
                std::fs::create_dir_all(dir)?;
            }
            std::fs::write(&path, format!("{n}\n"))?;
        }
        None => {
            let _ = std::fs::remove_file(&path);
        }
    }
    Ok(())
}

/// `dots/core`: the base layer.
pub fn core_dir(dots: &Path) -> PathBuf {
    dots.join("core")
}

/// Files that make up every config, given the active profile chain.
#[derive(Debug, Clone)]
pub struct Layers {
    /// base dots dir path(may has `core`, `profiles` dir)
    pub dots: PathBuf,
    /// Active profile and its ancestors, parents first (empty = no profile).
    pub chain: Vec<String>,
}

impl Layers {
    /// Resolve the chain for `active` (validated). `None` = core only.
    pub fn new(dots: &Path, active: Option<&str>) -> Result<Self> {
        let chain = match active {
            Some(name) => chain(dots, name)?,
            None => Vec::new(),
        };
        Ok(Self {
            dots: dots.to_path_buf(),
            chain,
        })
    }

    /// Base config only (tests, or tools that ignore profiles).
    pub fn base(dots: &Path) -> Self {
        Self {
            dots: dots.to_path_buf(),
            chain: Vec::new(),
        }
    }

    /// Layers for `rel`, relative to each layer root (e.g. `"dot.toml"`,
    /// `"shell/shared.toml"`): `core/<rel>`, then `profiles/<name>/<rel>` per profile.
    pub fn files(&self, rel: &str) -> Vec<Layer> {
        let mut v = Vec::with_capacity(1 + self.chain.len());
        v.push(Layer {
            path: core_dir(&self.dots).join(rel),
            dir: "core".to_string(),
        });
        for name in &self.chain {
            v.push(Layer {
                path: profile_dir(&self.dots, name).join(rel),
                dir: format!("profiles/{name}"),
            });
        }
        v
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tmp(name: &str) -> PathBuf {
        let d = std::env::temp_dir().join(format!("dot-profile-{name}-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&d);
        d
    }

    fn mk(dots: &Path, name: &str, meta: &str) {
        let dir = profile_dir(dots, name);
        std::fs::create_dir_all(&dir).unwrap();
        std::fs::write(dir.join("profile.toml"), meta).unwrap();
    }

    #[test]
    fn chain_parents_first_and_dedup() {
        let dots = tmp("chain");
        mk(&dots, "base", "");
        mk(&dots, "a", "extends = [\"base\"]");
        mk(&dots, "b", "extends = [\"base\"]");
        mk(&dots, "me", "extends = [\"a\", \"b\"]");
        assert_eq!(chain(&dots, "me").unwrap(), ["base", "a", "b", "me"]);
        std::fs::remove_dir_all(dots).unwrap();
    }

    #[test]
    fn chain_detects_cycles_and_missing() {
        let dots = tmp("cycle");
        mk(&dots, "x", "extends = [\"y\"]");
        mk(&dots, "y", "extends = [\"x\"]");
        assert!(chain(&dots, "x").unwrap_err().to_string().contains("cycle"));
        mk(&dots, "z", "extends = [\"nope\"]");
        assert!(
            chain(&dots, "z")
                .unwrap_err()
                .to_string()
                .contains("not found")
        );
        std::fs::remove_dir_all(dots).unwrap();
    }

    #[test]
    fn layers_order() {
        let dots = tmp("layers");
        mk(&dots, "p", "");
        mk(&dots, "c", "extends = [\"p\"]");
        let l = Layers::new(&dots, Some("c")).unwrap();
        let files: Vec<_> = l
            .files("shell/shared.toml")
            .into_iter()
            .map(|x| x.path)
            .collect();
        assert_eq!(
            files,
            [
                dots.join("core/shell/shared.toml"),
                dots.join("profiles/p/shell/shared.toml"),
                dots.join("profiles/c/shell/shared.toml"),
            ]
        );
        std::fs::remove_dir_all(dots).unwrap();
    }
}
