//! Generation-time conditions shared by env / alias / eval entries.

use schemars::JsonSchema;
use serde::Deserialize;

use crate::emit::Shell;

#[derive(Debug, Default, Deserialize, JsonSchema)]
pub struct Cond {
    /// Command name (looked up in PATH) or path (`~` allowed) that must exist.
    pub requires: Option<String>,
    /// Restrict to these OSes (`unix` = not windows, `wsl` = Linux under WSL). Empty = all.
    #[serde(default)]
    #[schemars(extend("items" = { "enum": ["windows", "linux", "macos", "unix", "wsl"] }))]
    pub os: Vec<String>,
    /// Restrict to these shells. Empty = all.
    #[serde(default)]
    pub shells: Vec<Shell>,
}

impl Cond {
    pub fn holds(&self, shell: Shell) -> bool {
        (self.shells.is_empty() || self.shells.contains(&shell))
            && (self.os.is_empty() || self.os.iter().any(|o| os_matches(o)))
            && self.requires.as_deref().is_none_or(exists)
    }
}

fn os_matches(name: &str) -> bool {
    match name {
        "unix" => cfg!(unix),
        "wsl" => is_wsl(),
        other => other == std::env::consts::OS,
    }
}

fn is_wsl() -> bool {
    cfg!(target_os = "linux") && std::env::var_os("WSL_DISTRO_NAME").is_some()
}

fn exists(req: &str) -> bool {
    dot_core::path::requirement_met(req)
}
