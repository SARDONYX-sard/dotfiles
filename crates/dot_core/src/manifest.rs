//! `dot.toml` schema (`dots/core/dot.toml`, `dots/profiles/<name>/dot.toml`).
//!
//! ```toml
//! [pkg.git]
//! [[pkg.git.link]]
//! src = "home/git/config"          # relative to `dots/`
//! dst = "~/.gitconfig"             # same on every OS
//!
//! [pkg.nvim]
//! os = ["windows", "linux"]        # optional filter
//! [[pkg.nvim.link]]
//! src = "home/nvim/init.lua"
//! dst.windows = "{localappdata}/nvim/init.lua"
//! dst.unix = "~/.config/nvim/init.lua"
//! ```

use std::collections::BTreeMap;
use std::path::PathBuf;

use anyhow::{Context as _, Result};
use schemars::JsonSchema;
use serde::Deserialize;

#[derive(Debug, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct Manifest {
    /// Packages keyed by name. Each package is a group of links that can be
    /// enabled/disabled or restricted to an OS together.
    #[serde(default)]
    pub pkg: BTreeMap<String, Package>,
    /// Defaults for `dot keyrate` (Windows).
    pub keyrate: Option<KeyRate>,
}

/// Key repeat beyond the Windows settings UI limits (FilterKeys).
#[derive(Debug, Clone, Copy, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct KeyRate {
    /// Milliseconds before a held key starts repeating.
    pub delay_ms: u32,
    /// Milliseconds between repeats.
    pub repeat_ms: u32,
    /// Store in the user profile so it survives sign-out/reboot.
    #[serde(default)]
    pub persist: bool,
}

#[derive(Debug, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct Package {
    /// Restrict to these OS names. Empty = all.
    #[serde(default)]
    #[schemars(extend("items" = { "enum": ["windows", "linux", "macos"] }))]
    pub os: Vec<String>,
    /// Set to false to skip this package (e.g. from a profile).
    #[serde(default = "default_true")]
    pub enabled: bool,
    /// Only link when this command (or `~/path`) exists, e.g. `"fish"`.
    pub requires: Option<String>,
    /// Symlinks to create.
    #[serde(default)]
    pub link: Vec<Link>,
}

#[derive(Debug, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct Link {
    /// Source path, relative to this layer's root (`dots/core/` or the profile dir),
    /// or a template for files outside the repo: `~/...`, `{appdata}/...`, etc.
    /// (e.g. `~/.local/state/dot/gen/init.nu` from `dot gen`).
    pub src: PathBuf,
    /// Destination. Tokens: `~`, `{documents}`, `{appdata}`, `{localappdata}`.
    pub dst: Dst,
}

#[derive(Debug, Deserialize, JsonSchema)]
#[serde(untagged)]
pub enum Dst {
    /// Same destination on every OS.
    Any(String),
    /// Different destination per OS. A missing key skips the link on that OS.
    PerOs {
        /// Destination on Windows.
        windows: Option<String>,
        /// Destination on Linux/macOS.
        unix: Option<String>,
    },
}

impl Dst {
    /// Destination template for the current OS, if any.
    pub fn current(&self) -> Option<&str> {
        match self {
            Dst::Any(s) => Some(s),
            Dst::PerOs { windows, unix } => {
                if cfg!(windows) {
                    windows.as_deref()
                } else {
                    unix.as_deref()
                }
            }
        }
    }
}

const fn default_true() -> bool {
    true
}

impl Package {
    pub fn applies_here(&self) -> bool {
        self.enabled
            && (self.os.is_empty() || self.os.iter().any(|o| o == std::env::consts::OS))
            && self
                .requires
                .as_deref()
                .is_none_or(crate::path::requirement_met)
    }
}

impl Manifest {
    /// Load `dot.toml` layers: core -> profiles.
    pub fn load(layers: &crate::profile::Layers) -> Result<Self> {
        let files = layers.files("dot.toml");
        crate::config::load_layers(&files, rebase_srcs)?
            .with_context(|| format!("{} not found", files[0].path.display()))
    }
}

/// Each layer writes `src` relative to its own root (`core/`, `profiles/<name>/`);
/// make it relative to `dots/` (`~/...` and `{token}/...` sources are left alone).
fn rebase_srcs(table: &mut toml::Table, dir: &str) {
    let Some(toml::Value::Table(pkgs)) = table.get_mut("pkg") else {
        return;
    };
    for (_, pkg) in pkgs.iter_mut() {
        let Some(toml::Value::Array(links)) = pkg.get_mut("link") else {
            continue;
        };
        for link in links {
            if let Some(toml::Value::String(src)) = link.get_mut("src")
                && !crate::path::is_template(src)
            {
                *src = format!("{dir}/{src}");
            }
        }
    }
}
