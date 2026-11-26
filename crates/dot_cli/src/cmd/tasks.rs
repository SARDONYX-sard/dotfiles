//! Runner for `[clean]` (`dot clean`) and `[upgrade]` (`dot upgrade`) entries of
//! tools.toml (formerly scripts/remove-cache.py and the shells' update_all_libs).

use std::process::Command;

use anyhow::{Context as _, Result, bail};
use dot_core::tools::Task;
use indexmap::IndexMap;

pub struct Opts {
    pub only: Vec<String>,
    pub skip: Vec<String>,
    pub dry_run: bool,
}

/// Run selected tasks in file order. Failures are reported at the end.
pub fn run(tasks: &IndexMap<String, Task>, opts: &Opts) -> Result<()> {
    for name in opts.only.iter().chain(&opts.skip) {
        if !tasks.contains_key(name) {
            let known = tasks.keys().cloned().collect::<Vec<_>>().join(", ");
            bail!("unknown entry `{name}` (known: {known})");
        }
    }

    let mut failed = Vec::new();
    for (name, task) in tasks {
        let selected =
            (opts.only.is_empty() || opts.only.contains(name)) && !opts.skip.contains(name);
        if !selected || !task.applies_here() {
            continue;
        }
        if let Some(req) = task
            .requires()
            .filter(|r| !dot_core::path::requirement_met(r))
        {
            println!("- {name}: skipped ({req} not found)");
            continue;
        }
        if let Some(other) = task.unless().filter(|u| dot_core::path::requirement_met(u)) {
            println!("- {name}: skipped ({other} is installed)");
            continue;
        }

        println!("\x1b[32m==> {name}\x1b[0m");
        for cmd in task.cmds() {
            println!("    $ {cmd}");
            if opts.dry_run {
                continue;
            }
            if let Err(e) = run_cmd(cmd) {
                eprintln!("    \x1b[31merror: {e:#}\x1b[0m");
                failed.push(name.clone());
                break;
            }
        }
        for p in task.paths() {
            let path = dot_core::path::expand(p)?;
            if !path.exists() {
                continue;
            }
            println!("    rm -r {}", path.display());
            if !opts.dry_run
                && let Err(e) = std::fs::remove_dir_all(&path)
            {
                eprintln!("    \x1b[31merror: {}: {e}\x1b[0m", path.display());
                failed.push(name.clone());
            }
        }
    }

    if failed.is_empty() {
        println!(
            "\x1b[32mdone{}\x1b[0m",
            if opts.dry_run { " (dry run)" } else { "" }
        );
        Ok(())
    } else {
        failed.dedup();
        bail!("failed: {}", failed.join(", "))
    }
}

/// Run a whitespace-separated command, resolving the program through PATH
/// (so Windows `npm.cmd`, `scoop.cmd` etc. work).
fn run_cmd(cmdline: &str) -> Result<()> {
    let mut parts = cmdline.split_whitespace();
    let prog = parts.next().context("empty command")?;
    let prog = which::which(prog).with_context(|| format!("{prog} not found"))?;
    let status = Command::new(&prog).args(parts).status()?;
    if !status.success() {
        bail!("exit status {status}");
    }
    Ok(())
}
