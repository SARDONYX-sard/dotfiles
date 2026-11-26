//! `shared.toml` schema.
//!
//! ```toml
//! [env]
//! DOCKER_CONTENT_TRUST = "1"
//! EDITOR = { value = "nvim", requires = "nvim" }
//!
//! [path]
//! prepend = ["~/.local/bin", "~/.cargo/bin"]   # only existing dirs are added
//!
//! [alias]
//! c = "clear"
//! cat = { cmd = "bat", requires = "bat" }
//! df = { cmd = "df -h", os = ["unix"] }
//! ".." = { cmd = "cd ..", shells = ["bash", "fish", "pwsh"] }
//!
//! [[eval]]                     # stdout is inlined into the generated script
//! requires = "zoxide"
//! bash = "zoxide init bash"
//! pwsh = "zoxide init powershell"
//! ```

use std::collections::BTreeMap;

use anyhow::{Context as _, Result};
use schemars::JsonSchema;
use serde::Deserialize;

use crate::cond::Cond;
use crate::emit::Shell;

#[derive(Debug, Default, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct Shared {
    /// Environment variables: `NAME = "value"` or `NAME = { value = "...", requires = "cmd" }`.
    #[serde(default)]
    pub env: BTreeMap<String, Env>,
    /// PATH entries.
    #[serde(default)]
    pub path: PathSpec,
    /// Aliases: `name = "command"` or `name = { cmd = "...", requires = "...", os = [...], shells = [...] }`.
    /// Arguments are appended. pwsh gets a function (built-in aliases like `gc` are removed).
    #[serde(default)]
    pub alias: BTreeMap<String, Alias>,
    /// Commands whose stdout is inlined into the generated script at `dot gen` time
    /// (e.g. `zoxide init`), so shells do not spawn them on startup.
    #[serde(default)]
    pub eval: Vec<Eval>,
}

impl Shared {
    /// Load `shell/shared.toml` layers: core -> profiles.
    pub fn load(layers: &dot_core::profile::Layers) -> Result<Self> {
        let files = layers.files("shell/shared.toml");
        dot_core::config::load_layers(&files, |_, _| {})?
            .with_context(|| format!("{} not found", files[0].path.display()))
    }
}

#[derive(Debug, Default, Deserialize, JsonSchema)]
#[serde(deny_unknown_fields)]
pub struct PathSpec {
    /// Directories to prepend; earlier entries come first. `~` is expanded and
    /// missing directories are skipped at generation time.
    #[serde(default)]
    pub prepend: Vec<String>,
}

#[derive(Debug, Deserialize, JsonSchema)]
#[serde(from = "EnvRepr")]
#[schemars(with = "EnvRepr")]
pub struct Env {
    pub value: String,
    pub cond: Cond,
}

#[derive(Deserialize, JsonSchema)]
#[serde(untagged)]
enum EnvRepr {
    /// Value, always set.
    Plain(String),
    /// Value with conditions.
    Full {
        /// Value.
        value: String,
        #[serde(flatten)]
        cond: Cond,
    },
}

impl From<EnvRepr> for Env {
    fn from(r: EnvRepr) -> Self {
        match r {
            EnvRepr::Plain(value) => Self {
                value,
                cond: Cond::default(),
            },
            EnvRepr::Full { value, cond } => Self { value, cond },
        }
    }
}

#[derive(Debug, Deserialize, JsonSchema)]
#[serde(from = "AliasRepr")]
#[schemars(with = "AliasRepr")]
pub struct Alias {
    pub cmd: String,
    pub cond: Cond,
}

#[derive(Deserialize, JsonSchema)]
#[serde(untagged)]
enum AliasRepr {
    /// Command, always defined.
    Plain(String),
    /// Command with conditions.
    Full {
        /// Command; arguments given to the alias are appended.
        cmd: String,
        #[serde(flatten)]
        cond: Cond,
    },
}

impl From<AliasRepr> for Alias {
    fn from(r: AliasRepr) -> Self {
        match r {
            AliasRepr::Plain(cmd) => Self {
                cmd,
                cond: Cond::default(),
            },
            AliasRepr::Full { cmd, cond } => Self { cmd, cond },
        }
    }
}

#[derive(Debug, Deserialize, JsonSchema)]
pub struct Eval {
    #[serde(flatten)]
    pub cond: Cond,
    /// pwsh: move into `init.lazy.ps1`, loaded after the first prompt.
    #[serde(default)]
    pub lazy: bool,
    /// Command line for bash (split on whitespace, no shell quoting).
    pub bash: Option<String>,
    /// Command line for fish.
    pub fish: Option<String>,
    /// Command line for pwsh.
    pub pwsh: Option<String>,
    /// Command line for nu.
    pub nu: Option<String>,
}

impl Eval {
    pub fn command_for(&self, shell: Shell) -> Option<&str> {
        match shell {
            Shell::Bash => self.bash.as_deref(),
            Shell::Fish => self.fish.as_deref(),
            Shell::Pwsh => self.pwsh.as_deref(),
            Shell::Nu => self.nu.as_deref(),
        }
    }
}
