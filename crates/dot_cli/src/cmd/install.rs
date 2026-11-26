//! `dot install`: install the `[install.*]` groups of tools.toml (core + profiles).
//!
//! Each group becomes a task for the shared runner (`cmd::tasks`): skipped when
//! its package manager is missing, run in file order. Package managers skip
//! already-installed packages themselves, so re-running is safe.

use anyhow::{Result, bail};
use dot_core::tools::{Cmds, Task, ToolGroup, Via};
use indexmap::IndexMap;

use super::tasks;

/// Install command for `via`; `each` = the manager takes one package per call.
fn builtin(via: Via) -> (&'static str, bool) {
    match via {
        Via::Scoop => ("scoop install", false),
        // No `sudo`: Windows' sudo.exe defaults to a new window, so output and
        // exit status would be lost. Elevation is checked in `to_task` instead.
        Via::ScoopGlobal => ("scoop install --global", false),
        Via::ScoopBucket => ("scoop bucket add", true),
        Via::Winget => (
            "winget install --exact --accept-package-agreements --accept-source-agreements --id",
            true,
        ),
        Via::Cargo if which::which("cargo-binstall").is_ok() => ("cargo binstall -y", false),
        Via::Cargo => ("cargo install", false),
        Via::Apt => ("sudo apt install -y", false),
        Via::Pacman => ("sudo pacman -S --needed --noconfirm", false),
        Via::Brew => ("brew install", false),
        Via::Pipx => ("pipx install", false),
        Via::Npm => ("npm install -g", false),
    }
}

/// `$SCOOP/buckets/<name>` (default `~/scoop`). `entry` may be `"name url"`.
fn scoop_bucket_exists(entry: &str) -> bool {
    let name = entry.split_whitespace().next().unwrap_or(entry);
    let root = std::env::var_os("SCOOP")
        .map(std::path::PathBuf::from)
        .or_else(|| dirs::home_dir().map(|h| h.join("scoop")));
    root.is_some_and(|r| r.join("buckets").join(name).is_dir())
}

/// Whether this process runs as administrator (always true off Windows; the
/// commands there use `sudo` themselves).
fn is_elevated() -> bool {
    #[cfg(windows)]
    {
        #[link(name = "shell32")]
        unsafe extern "system" {
            fn IsUserAnAdmin() -> i32;
        }
        // SAFETY: no arguments; only queries the current process token.
        unsafe { IsUserAnAdmin() != 0 }
    }
    #[cfg(not(windows))]
    {
        true
    }
}

/// `None` when there is nothing left to do (e.g. all buckets already added).
fn to_task(name: &str, g: &ToolGroup) -> Result<Option<Task>> {
    let (cmd, each) = match (&g.cmd, g.via) {
        (Some(c), _) => (c.clone(), g.each),
        (None, Some(v)) => {
            let (c, each) = builtin(v);
            (c.to_string(), each || g.each)
        }
        (None, None) => bail!("[install.{name}] needs `via` or `cmd`"),
    };
    if g.cmd.is_none() && g.via == Some(Via::ScoopGlobal) && !is_elevated() {
        println!("- {name}: skipped (needs an elevated shell for `scoop install --global`)");
        return Ok(None);
    }
    // `scoop bucket add` fails (exit 2) for buckets that already exist.
    let packages: Vec<&String> = if g.cmd.is_none() && g.via == Some(Via::ScoopBucket) {
        g.packages
            .iter()
            .filter(|p| !scoop_bucket_exists(p))
            .collect()
    } else {
        g.packages.iter().collect()
    };
    if packages.is_empty() {
        println!("- {name}: nothing to do");
        return Ok(None);
    }
    let lines = if each {
        packages.iter().map(|p| format!("{cmd} {p}")).collect()
    } else {
        vec![format!(
            "{cmd} {}",
            packages
                .iter()
                .map(|p| p.as_str())
                .collect::<Vec<_>>()
                .join(" ")
        )]
    };
    Ok(Some(Task::Full {
        cmd: Some(Cmds::Many(lines)),
        paths: Vec::new(),
        requires: None, // program of the command (sudo skipped)
        unless: None,
        os: g.os.clone(),
    }))
}

pub fn run(groups: &IndexMap<String, ToolGroup>, opts: &tasks::Opts) -> Result<()> {
    // Select by group name here: groups with nothing to do never become tasks.
    for name in opts.only.iter().chain(&opts.skip) {
        if !groups.contains_key(name) {
            let known = groups.keys().cloned().collect::<Vec<_>>().join(", ");
            bail!("unknown group `{name}` (known: {known})");
        }
    }
    let mut tasks_map = IndexMap::new();
    for (name, g) in groups {
        let selected =
            (opts.only.is_empty() || opts.only.contains(name)) && !opts.skip.contains(name);
        if !selected {
            continue;
        }
        if let Some(task) = to_task(name, g)? {
            tasks_map.insert(name.clone(), task);
        }
    }
    let opts = tasks::Opts {
        only: Vec::new(),
        skip: Vec::new(),
        dry_run: opts.dry_run,
    };
    tasks::run(&tasks_map, &opts)
}
