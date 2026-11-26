//! Deploy history (`~/.local/state/dot/state.json`), used by `dot rollback`.

use std::path::{Path, PathBuf};

use anyhow::{Context as _, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct State {
    pub transactions: Vec<Transaction>,
}

/// One `dot deploy` run.
#[derive(Debug, Serialize, Deserialize)]
pub struct Transaction {
    /// Unix seconds.
    pub time: u64,
    pub ops: Vec<Op>,
}

/// One destination changed by a deploy.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Op {
    pub dst: PathBuf,
    /// Source the deploy linked `dst` to; `None` when the deploy only removed `dst`
    /// (`--prune`).
    pub src: Option<PathBuf>,
    pub before: Before,
}

/// What `dst` was before the deploy touched it.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "lowercase")]
pub enum Before {
    Missing,
    /// A symlink (raw target as stored in the link).
    Link {
        target: PathBuf,
        dir: bool,
    },
    /// A real file/dir, moved to `path`.
    Backup {
        path: PathBuf,
    },
}

impl State {
    pub fn default_path() -> Result<PathBuf> {
        let home = dirs::home_dir().context("home directory not found")?;
        Ok(home
            .join(".local")
            .join("state")
            .join("dot")
            .join("state.json"))
    }

    pub fn load(path: &Path) -> Result<Self> {
        match std::fs::read_to_string(path) {
            Ok(text) => serde_json::from_str(&text)
                .with_context(|| format!("failed to parse {}", path.display())),
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(Self::default()),
            Err(e) => Err(e).with_context(|| format!("failed to read {}", path.display())),
        }
    }

    pub fn save(&self, path: &Path) -> Result<()> {
        if let Some(dir) = path.parent() {
            std::fs::create_dir_all(dir)?;
        }
        let tmp = path.with_extension("json.tmp");
        std::fs::write(&tmp, serde_json::to_string_pretty(self)?)?;
        std::fs::rename(&tmp, path).with_context(|| format!("failed to write {}", path.display()))
    }
}

/// `~/.local/state/dot/root`: the dotfiles repo used last, so `dot` also works
/// outside it (before the shell has set `$DOT_ROOT`).
fn root_file() -> Result<PathBuf> {
    Ok(State::default_path()?.with_file_name("root"))
}

/// Repo root saved by [`save_root`], if it still contains `dots/core/dot.toml`.
pub fn saved_root() -> Option<PathBuf> {
    let text = std::fs::read_to_string(root_file().ok()?).ok()?;
    let root = PathBuf::from(text.trim());
    root.join("dots")
        .join("core")
        .join("dot.toml")
        .is_file()
        .then_some(root)
}

/// Remember `root` for [`saved_root`] (no-op when unchanged).
pub fn save_root(root: &Path) -> Result<()> {
    let file = root_file()?;
    let value = root.display().to_string();
    if std::fs::read_to_string(&file).is_ok_and(|t| t.trim() == value) {
        return Ok(());
    }
    if let Some(dir) = file.parent() {
        std::fs::create_dir_all(dir)?;
    }
    std::fs::write(&file, value + "\n")?;
    Ok(())
}
