//! `tools.toml` (core + profiles): package management for `dot install`, `dot upgrade`, `dot clean`.

use anyhow::Result;
use indexmap::IndexMap;
use schemars::JsonSchema;
use serde::Deserialize;

#[derive(Debug, Default, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct Tools {
    /// `dot install`: package groups in file order (put bucket/repo setup before the
    /// groups that need it). Keyed by group name (`--only`/`--skip`).
    #[serde(default)]
    pub install: IndexMap<String, ToolGroup>,
    /// `dot upgrade`: package managers / toolchains to update, in file order.
    #[serde(default)]
    pub upgrade: IndexMap<String, Task>,
    /// `dot clean`: caches to clean, in file order.
    #[serde(default)]
    pub clean: IndexMap<String, Task>,
}

impl Tools {
    /// Load `tools.toml` layers: core -> profiles; missing = empty.
    pub fn load(layers: &crate::profile::Layers) -> Result<Self> {
        Ok(crate::config::load_layers(&layers.files("tools.toml"), |_, _| {})?.unwrap_or_default())
    }
}

/// Package manager with a built-in install command.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum Via {
    /// `scoop install`
    Scoop,
    /// `scoop install --global` (skipped unless run from an elevated shell)
    ScoopGlobal,
    /// `scoop bucket add` (one per entry; e.g. `"extras"` or `"name https://repo"`)
    ScoopBucket,
    /// `winget install --exact --id` (one per entry)
    Winget,
    /// `cargo binstall -y` when cargo-binstall is installed, else `cargo install`
    Cargo,
    /// `sudo apt install -y`
    Apt,
    /// `sudo pacman -S --needed --noconfirm`
    Pacman,
    /// `brew install`
    Brew,
    /// `pipx install`
    Pipx,
    /// `npm install -g`
    Npm,
}

/// A group of packages installed with one package manager.
#[derive(Debug, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct ToolGroup {
    /// Package manager (sets the install command).
    pub via: Option<Via>,
    /// Custom install command (packages are appended); overrides `via`.
    pub cmd: Option<String>,
    /// Package names (or bucket names for `scoop_bucket`).
    #[serde(default)]
    pub packages: Vec<String>,
    /// Run the command once per package instead of once with all of them.
    #[serde(default)]
    pub each: bool,
    /// Restrict to these OS names. Empty = all.
    #[serde(default)]
    #[schemars(extend("items" = { "enum": ["windows", "linux", "macos"] }))]
    pub os: Vec<String>,
}

/// One or more command lines.
#[derive(Debug, Clone, Deserialize, JsonSchema)]
#[serde(untagged)]
pub enum Cmds {
    One(String),
    /// Run in order; the task stops at the first failure.
    Many(Vec<String>),
}

impl Cmds {
    pub fn as_slice(&self) -> &[String] {
        match self {
            Cmds::One(s) => std::slice::from_ref(s),
            Cmds::Many(v) => v,
        }
    }
}

/// A `dot clean` / `dot upgrade` entry: commands, directories to delete, or both.
///
/// Commands are split on whitespace and run without a shell (no globbing,
/// quoting or pipes). Programs are looked up in PATH (Windows `.cmd` works).
#[derive(Debug, Deserialize, JsonSchema)]
#[serde(untagged)]
pub enum Task {
    /// Command line(s). Runs only if the program exists.
    Cmd(Cmds),
    /// Full form.
    Full {
        /// Command line(s).
        cmd: Option<Cmds>,
        /// Directories to delete (`~` allowed). Missing ones are skipped.
        #[serde(default)]
        paths: Vec<String>,
        /// Command or path that must exist (default: the program of the first `cmd`,
        /// ignoring a leading `sudo`).
        requires: Option<String>,
        /// Skip when this command exists (e.g. pacman `unless = "yay"`).
        unless: Option<String>,
        /// Restrict to these OS names. Empty = all.
        #[serde(default)]
        #[schemars(extend("items" = { "enum": ["windows", "linux", "macos"] }))]
        os: Vec<String>,
    },
}

impl Task {
    pub fn cmds(&self) -> &[String] {
        match self {
            Task::Cmd(c) | Task::Full { cmd: Some(c), .. } => c.as_slice(),
            Task::Full { cmd: None, .. } => &[],
        }
    }

    pub fn paths(&self) -> &[String] {
        match self {
            Task::Cmd(_) => &[],
            Task::Full { paths, .. } => paths,
        }
    }

    /// Explicit `requires`, else the program of the first command (skipping `sudo`).
    pub fn requires(&self) -> Option<&str> {
        if let Task::Full {
            requires: Some(r), ..
        } = self
        {
            return Some(r);
        }
        let mut words = self.cmds().first()?.split_whitespace();
        let first = words.next()?;
        if first == "sudo" {
            words.next()
        } else {
            Some(first)
        }
    }

    pub fn unless(&self) -> Option<&str> {
        match self {
            Task::Full { unless, .. } => unless.as_deref(),
            Task::Cmd(_) => None,
        }
    }

    pub fn applies_here(&self) -> bool {
        match self {
            Task::Full { os, .. } if !os.is_empty() => os.iter().any(|o| o == std::env::consts::OS),
            _ => true,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tasks_keep_order_and_infer_requires() {
        let m: Tools = toml::from_str(
            r#"
            [upgrade]
            zeta = "rustup update"
            apt = ["sudo apt update -y", "sudo apt upgrade -y"]
            pacman = { cmd = "sudo pacman -Syu", unless = "yay" }
            cargo = { cmd = "cargo install-update -a", requires = "cargo-install-update" }
            dirs = { paths = ["~/.cache/x"], os = ["linux"] }
            "#,
        )
        .unwrap();
        let names: Vec<_> = m.upgrade.keys().map(String::as_str).collect();
        assert_eq!(
            names,
            ["zeta", "apt", "pacman", "cargo", "dirs"],
            "file order, not sorted"
        );

        assert_eq!(m.upgrade["zeta"].requires(), Some("rustup"));
        assert_eq!(
            m.upgrade["apt"].requires(),
            Some("apt"),
            "leading sudo ignored"
        );
        assert_eq!(m.upgrade["apt"].cmds().len(), 2);
        assert_eq!(m.upgrade["pacman"].unless(), Some("yay"));
        assert_eq!(m.upgrade["cargo"].requires(), Some("cargo-install-update"));
        assert_eq!(m.upgrade["dirs"].requires(), None);
        assert_eq!(m.upgrade["dirs"].paths(), ["~/.cache/x"]);
    }
}
