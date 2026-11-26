//! Generate per-shell init scripts from `shell/shared.toml` (core + profiles).
//!
//! Every condition (`requires`, `os`) is evaluated at generation time, so the
//! emitted scripts contain no runtime checks and start fast. Re-run `dot gen`
//! after installing/removing tools.

mod cond;
mod emit;
mod schema;

use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context as _, Result};

pub use emit::Shell;
pub use schema::Shared;

/// Directory where generated scripts are written: `~/.local/state/dot/gen`.
pub fn out_dir() -> Result<PathBuf> {
    let home = dirs::home_dir().context("home directory not found")?;
    Ok(home.join(".local").join("state").join("dot").join("gen"))
}

/// Shells to generate for by default: the installed ones (pwsh counts Windows
/// PowerShell 5.1 too, since one profile serves both).
pub fn default_shells() -> Vec<Shell> {
    let has = |cmds: &[&str]| cmds.iter().any(|c| which::which(c).is_ok());
    [
        (Shell::Bash, &["bash"][..]),
        (Shell::Fish, &["fish"][..]),
        (Shell::Pwsh, &["pwsh", "powershell"][..]),
        (Shell::Nu, &["nu"][..]),
    ]
    .into_iter()
    .filter(|(_, cmds)| has(cmds))
    .map(|(s, _)| s)
    .collect()
}

/// Generated scripts for one shell.
pub struct Generated {
    pub main: String,
    /// pwsh only: `lazy = true` evals, sourced by the profile on first idle.
    pub lazy: Option<String>,
}

/// Generate the script(s) for one shell. `repo_root` is exported as `DOT_ROOT`, so
/// shell configs can find their sibling files without resolving symlinks.
pub fn generate(shared: &Shared, shell: Shell, repo_root: &Path) -> Result<Generated> {
    let mut out = emit::Emitter::new(shell);
    out.header();
    let mut lazy = (shell == Shell::Pwsh).then(|| {
        let mut e = emit::Emitter::new(shell);
        e.header();
        e
    });

    let root = repo_root.display().to_string();
    let env: Vec<_> = std::iter::once(("DOT_ROOT", root.as_str()))
        .chain(
            shared
                .env
                .iter()
                .filter(|(_, e)| e.cond.holds(shell))
                .map(|(k, e)| (k.as_str(), e.value.as_str())),
        )
        .collect();
    out.env(&env);

    let mut paths = Vec::new();
    for p in &shared.path.prepend {
        let p = dot_core::path::expand(p)?;
        if p.is_dir() {
            paths.push(p.display().to_string());
        }
    }
    out.path_prepend(&paths);

    let aliases: Vec<_> = shared
        .alias
        .iter()
        .filter(|(_, a)| a.cond.holds(shell))
        .map(|(k, a)| (k.as_str(), a.cmd.as_str()))
        .collect();
    out.aliases(&aliases);

    for ev in &shared.eval {
        if !ev.cond.holds(shell) {
            continue;
        }
        let Some(cmdline) = ev.command_for(shell) else {
            continue;
        };
        let text = match run(cmdline) {
            Ok(text) => text,
            Err(e) => {
                eprintln!("warning: eval `{cmdline}` failed: {e:#}");
                continue;
            }
        };
        let target = match lazy.as_mut() {
            Some(l) if ev.lazy => l,
            _ => &mut out,
        };
        target.raw(&format!("# eval: {cmdline}"), &text);
    }

    Ok(Generated {
        main: out.finish(),
        lazy: lazy.map(emit::Emitter::finish),
    })
}

/// Where the script for `shell` is written. Always under [`out_dir`], so `dot gen`
/// never touches live shell config; wiring it in is the job of `dot deploy`
/// (e.g. nu's autoload link in `dot.toml`), which `dot rollback` can undo.
pub fn out_path(shell: Shell) -> Result<PathBuf> {
    Ok(out_dir()?.join(format!("init.{}", shell.ext())))
}

/// Generate all `shells`, returning written paths.
pub fn generate_all(layers: &dot_core::profile::Layers, shells: &[Shell]) -> Result<Vec<PathBuf>> {
    let dots_dir = layers.dots.as_path();
    let shared = Shared::load(layers)?;
    let mut written = Vec::new();
    for &shell in shells {
        let root = dots_dir.parent().unwrap_or(dots_dir);
        let generated = generate(&shared, shell, root)?;
        let path = out_path(shell)?;
        if let Some(lazy) = &generated.lazy {
            let lazy_path = path.with_extension(format!("lazy.{}", shell.ext()));
            write(&lazy_path, lazy)?;
            written.push(lazy_path);
        }
        write(&path, &generated.main)?;
        written.push(path);
    }
    Ok(written)
}

fn write(path: &Path, text: &str) -> Result<()> {
    if let Some(dir) = path.parent() {
        std::fs::create_dir_all(dir)
            .with_context(|| format!("failed to create {}", dir.display()))?;
    }
    std::fs::write(path, text).with_context(|| format!("failed to write {}", path.display()))
}

/// Run a whitespace-separated command line and capture stdout.
fn run(cmdline: &str) -> Result<String> {
    let mut parts = cmdline.split_whitespace();
    let prog = parts.next().context("empty command")?;
    // Resolve through PATH so Windows `.cmd`/`.bat` shims (npm, ...) work too.
    let prog = which::which(prog).with_context(|| format!("{prog} not found"))?;
    let out = Command::new(prog).args(parts).output()?;
    anyhow::ensure!(out.status.success(), "exit status {}", out.status);
    Ok(String::from_utf8_lossy(&out.stdout).replace("\r\n", "\n"))
}
