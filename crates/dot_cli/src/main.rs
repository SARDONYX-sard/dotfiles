mod cmd;

/// `println!` that exits quietly when stdout is closed (e.g. `dot deploy -n | head`).
macro_rules! outln {
    ($($t:tt)*) => {{
        use std::io::Write as _;
        if writeln!(std::io::stdout(), $($t)*).is_err() {
            std::process::exit(0);
        }
    }};
}

use std::path::{Path, PathBuf};
use std::time::Duration;

use anyhow::{Context as _, Result};
use clap::{Parser, Subcommand};
use dot_core::profile::Layers;
use dot_core::{Manifest, Plan};
use dot_shellgen::Shell;

#[derive(Parser)]
#[command(name = "dot", version, about = "Cross-platform dotfiles manager")]
struct Cli {
    /// dotfiles repo root (default: $DOT_ROOT, then search upward from cwd)
    #[arg(long, global = true, env = "DOT_ROOT")]
    root: Option<PathBuf>,

    /// Profile to layer over the base config (default: $DOT_PROFILE, then the one
    /// saved by `dot profile use`). `--profile ''` = base config only.
    #[arg(long, global = true, env = "DOT_PROFILE")]
    profile: Option<String>,

    #[command(subcommand)]
    cmd: Cmd,
}

#[derive(Subcommand)]
enum ProfileCmd {
    /// List profiles (`*` = active).
    List,
    /// Show the active profile and its inheritance chain.
    Show,
    /// Make a profile active on this machine (stored outside the repo).
    Use {
        name: Option<String>,
        /// Clear the active profile.
        #[arg(long, conflicts_with = "name")]
        clear: bool,
    },
    /// Create an empty profile in dots/profiles/<name>.
    New {
        name: String,
        /// Profiles to inherit from (comma separated).
        #[arg(long, value_delimiter = ',')]
        extends: Vec<String>,
        #[arg(long)]
        description: Option<String>,
    },
    /// Pack a profile into <name>.tar.gz.
    Export {
        name: String,
        /// Output file (default: ./<name>.tar.gz).
        #[arg(long, short)]
        output: Option<PathBuf>,
    },
    /// Add a profile from a directory, an exported archive, or `<git-url>#<name>`.
    Import {
        src: String,
        /// Name to import as (default: the source's name).
        #[arg(long = "as")]
        as_name: Option<String>,
        /// Replace an existing profile with the same name.
        #[arg(long)]
        force: bool,
    },
}

#[derive(Subcommand)]
enum Cmd {
    /// Manage profiles: personal layers in dots/profiles/<name> (inheritable).
    Profile {
        #[command(subcommand)]
        cmd: ProfileCmd,
    },
    /// Link files from `dots/` into place.
    Deploy {
        /// Print the plan without touching the filesystem.
        #[arg(long, short = 'n')]
        dry_run: bool,
        /// Replace conflicting real files (they are moved to the backup dir first).
        #[arg(long)]
        force: bool,
        /// Also remove unmanaged symlinks into this repo (undoable with rollback).
        #[arg(long)]
        prune: bool,
    },
    /// Create one symlink `dst` -> `src` (like `ln -s src dst`), undoable with rollback.
    Link {
        /// Existing file or directory to point to (`~`, `{appdata}`... allowed).
        src: String,
        /// Link to create.
        dst: String,
        /// Replace an existing `dst` (real files are backed up first).
        #[arg(long, short)]
        force: bool,
        /// Show what would happen without changing anything.
        #[arg(long, short = 'n')]
        dry_run: bool,
    },
    /// Interactive UI: link states / deploy / rollback, profiles and where each value comes from.
    Tui,
    /// Undo the most recent deploy.
    Rollback {
        #[arg(long, short = 'n')]
        dry_run: bool,
    },
    /// Clean package-manager caches listed in `[clean]` of tools.toml.
    Clean {
        /// Only these caches (comma separated names).
        #[arg(long, value_delimiter = ',')]
        only: Vec<String>,
        /// Skip these caches (comma separated names).
        #[arg(long, value_delimiter = ',')]
        skip: Vec<String>,
        /// Print what would run without running it.
        #[arg(long, short = 'n')]
        dry_run: bool,
    },
    /// Upgrade package managers / toolchains listed in `[upgrade]` of tools.toml.
    Upgrade {
        /// Only these entries (comma separated names).
        #[arg(long, value_delimiter = ',')]
        only: Vec<String>,
        /// Skip these entries (comma separated names).
        #[arg(long, value_delimiter = ',')]
        skip: Vec<String>,
        /// Print what would run without running it.
        #[arg(long, short = 'n')]
        dry_run: bool,
    },
    /// Install the tool groups listed in `[install.*]` of tools.toml (safe to re-run).
    Install {
        /// Only these groups (comma separated names).
        #[arg(long, value_delimiter = ',')]
        only: Vec<String>,
        /// Skip these groups (comma separated names).
        #[arg(long, value_delimiter = ',')]
        skip: Vec<String>,
        /// Print what would run without running it.
        #[arg(long, short = 'n')]
        dry_run: bool,
    },
    /// Write JSON Schemas for the TOML configs into `dots/schemas/`.
    Schema,
    /// Generate shell init scripts from `shell/shared.toml` (core + profiles).
    Gen {
        /// Shells to generate (default: the installed ones).
        #[arg(long, short, value_delimiter = ',')]
        shell: Vec<Shell>,
        /// Print to stdout instead of writing files.
        #[arg(long)]
        stdout: bool,
    },
    /// Render the prompt. Called by each shell on every prompt.
    Prompt {
        #[arg(long, default_value = "plain")]
        shell: String,
        /// Exit status of the last command.
        #[arg(long, default_value_t = 0, allow_negative_numbers = true)]
        status: i32,
        /// Duration of the last command in milliseconds.
        #[arg(long)]
        duration: Option<f64>,
        #[arg(long, default_value_t = 300)]
        git_timeout_ms: u64,
        /// Print only the status line; the shell draws the input line (vi mode).
        #[arg(long)]
        status_only: bool,
        /// Running as admin/root (prompt shows `#`).
        #[arg(long)]
        admin: bool,
    },
    /// Locate an executable in PATH (resolves scoop shims).
    Which {
        name: String,
        /// Show every match, not just the first.
        #[arg(short, long)]
        all: bool,
    },
    /// Key repeat delay/rate beyond the Windows UI limits (default: `[keyrate]` in dot.toml).
    Keyrate {
        /// Delay before repeating, in ms.
        #[arg(requires = "repeat_ms")]
        delay_ms: Option<u32>,
        /// Interval between repeats, in ms.
        repeat_ms: Option<u32>,
        /// Disable (back to the Windows keyboard settings).
        #[arg(long, conflicts_with_all = ["delay_ms", "show"])]
        off: bool,
        /// Print the current setting.
        #[arg(long, conflicts_with = "delay_ms")]
        show: bool,
        /// Persist across sign-out/reboot (overrides the config).
        #[arg(long)]
        persist: bool,
    },
    /// Show a file, directory or command's binary in the OS file manager (selected).
    Reveal {
        /// Path or command name (default: current directory).
        target: Option<String>,
        /// Only print the resolved path.
        #[arg(long, short = 'n')]
        dry_run: bool,
    },
    /// Print ANSI color tables (16 colors with attributes; `--256` for the palette).
    Colors {
        /// Show the 256-color palette instead.
        #[arg(long = "256")]
        all_256: bool,
    },
    /// Convert CRLF to LF recursively (respects .gitignore, skips binaries).
    Tolf {
        /// Files or directories (default: current directory).
        paths: Vec<PathBuf>,
        /// Only these extensions, e.g. `-e rs,toml`.
        #[arg(short, long, value_delimiter = ',')]
        ext: Vec<String>,
        /// Include hidden files.
        #[arg(long)]
        hidden: bool,
        /// List files that would change without writing.
        #[arg(long, short = 'n')]
        dry_run: bool,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    // Commands that do not need the dotfiles repo.
    match &cli.cmd {
        Cmd::Which { name, all } => return cmd::which::run(name, *all),
        Cmd::Link {
            src,
            dst,
            force,
            dry_run,
        } => return cmd::link::run(src, dst, *force, *dry_run),
        // History lives in ~/.local/state/dot; works outside the repo too.
        Cmd::Rollback { dry_run } => {
            let opts = dot_core::apply::Options::default_paths(false)?;
            for line in dot_core::apply::rollback(&opts, *dry_run)? {
                outln!("{line}");
            }
            return Ok(());
        }
        Cmd::Colors { all_256 } => {
            cmd::colors::run(*all_256);
            return Ok(());
        }
        Cmd::Reveal { target, dry_run } => return cmd::reveal::run(target.as_deref(), *dry_run),
        Cmd::Tolf {
            paths,
            ext,
            hidden,
            dry_run,
        } => {
            return cmd::tolf::run(&cmd::tolf::Opts {
                paths: paths.clone(),
                ext: ext.clone(),
                hidden: *hidden,
                dry_run: *dry_run,
            });
        }
        Cmd::Keyrate {
            delay_ms,
            repeat_ms,
            off,
            show,
            persist,
        } => {
            use cmd::keyrate::Request;
            let req = if *show {
                Request::Show
            } else if *off {
                Request::Off { persist: *persist }
            } else if let (Some(d), Some(r)) = (delay_ms, repeat_ms) {
                Request::Set {
                    delay_ms: *d,
                    repeat_ms: *r,
                    persist: *persist,
                }
            } else {
                let root = match &cli.root {
                    Some(r) => r.clone(),
                    None => find_root(&std::env::current_dir()?)?,
                };
                let dots = root.join("dots");
                let layers = Layers::new(&dots, active_profile(cli.profile.as_deref()).as_deref())?;
                let cfg = Manifest::load(&layers)?.keyrate.context(
                    "no [keyrate] in dot.toml (core or profile); pass <delay_ms> <repeat_ms>",
                )?;
                Request::Set {
                    delay_ms: cfg.delay_ms,
                    repeat_ms: cfg.repeat_ms,
                    persist: cfg.persist || *persist,
                }
            };
            return cmd::keyrate::run(req);
        }
        _ => {}
    }

    if let Cmd::Prompt {
        shell,
        status,
        duration,
        git_timeout_ms,
        admin,
        status_only,
    } = &cli.cmd
    {
        let args = dot_prompt::Args {
            target: if shell == "bash" {
                dot_prompt::Target::Bash
            } else {
                dot_prompt::Target::Plain
            },
            status: *status,
            duration_ms: duration.map(|d| d as u64),
            git_timeout: Duration::from_millis(*git_timeout_ms),
            admin: *admin,
            status_only: *status_only,
        };
        let cwd = std::env::current_dir()?;
        print!("{}", dot_prompt::render(&cwd, &args));
        return Ok(());
    }

    let root = match cli.root {
        Some(r) => r,
        None => find_root(&std::env::current_dir()?)?,
    };
    let root = dot_core::path::canonical(&root);
    let dots = root.join("dots");
    let active = active_profile(cli.profile.as_deref());
    let layers = || Layers::new(&dots, active.as_deref());
    // Commands that set this machine up remember the repo for later runs elsewhere.
    if matches!(
        cli.cmd,
        Cmd::Gen { .. } | Cmd::Deploy { dry_run: false, .. } | Cmd::Profile { .. }
    ) {
        dot_core::state::save_root(&root)?;
    }

    match cli.cmd {
        Cmd::Profile { cmd } => match cmd {
            ProfileCmd::List => cmd::profile::list(&dots, active.as_deref())?,
            ProfileCmd::Show => cmd::profile::show(&dots, active.as_deref())?,
            ProfileCmd::Use { name, clear } => {
                if name.is_none() && !clear {
                    anyhow::bail!("usage: dot profile use <name> | --clear");
                }
                cmd::profile::use_profile(&dots, name.as_deref())?;
            }
            ProfileCmd::New {
                name,
                extends,
                description,
            } => {
                cmd::profile::new(&dots, &name, &extends, description.as_deref())?;
            }
            ProfileCmd::Export { name, output } => {
                cmd::profile::export(&dots, &name, output.as_deref())?
            }
            ProfileCmd::Import {
                src,
                as_name,
                force,
            } => {
                cmd::profile::import(&dots, &src, as_name.as_deref(), force)?;
            }
        },
        Cmd::Deploy {
            dry_run,
            force,
            prune,
        } => {
            if let Some(p) = &active {
                outln!("profile: {p}");
            }
            let manifest = Manifest::load(&layers()?)?;
            let plan = Plan::build(&manifest, &root, &dots)?;
            for e in &plan.entries {
                outln!(
                    "[{}] {} -> {}\n    {}",
                    e.pkg,
                    e.dst.display(),
                    e.src.display(),
                    e.action
                );
            }
            let unmanaged = dot_core::plan::unmanaged_links(&plan, &root);
            if !unmanaged.is_empty() {
                outln!(
                    "\nunmanaged links into this repo (add to dot.toml, or they dangle after the swap):"
                );
                for (link, target) in &unmanaged {
                    outln!("    {} -> {}", link.display(), target.display());
                }
            }
            if !dry_run {
                let mut opts = dot_core::apply::Options::default_paths(force)?;
                if prune {
                    opts.prune = unmanaged.iter().map(|(l, _)| l.clone()).collect();
                }
                let report = dot_core::apply::apply(&plan, &opts)?;
                if let Some(p) = &report.restore_script {
                    outln!("restore script (if `dot` is unavailable): {}", p.display());
                }
                for (dst, why) in &report.skipped {
                    eprintln!("skipped {}: {why}", dst.display());
                }
                outln!("linked {} (undo: dot rollback)", report.changed.len());
            }
        }
        Cmd::Tui => dot_tui::run(&root, active.clone())?,
        Cmd::Clean {
            only,
            skip,
            dry_run,
        } => {
            let tools = dot_core::tools::Tools::load(&layers()?)?;
            cmd::tasks::run(
                &tools.clean,
                &cmd::tasks::Opts {
                    only,
                    skip,
                    dry_run,
                },
            )?;
        }
        Cmd::Upgrade {
            only,
            skip,
            dry_run,
        } => {
            let tools = dot_core::tools::Tools::load(&layers()?)?;
            cmd::tasks::run(
                &tools.upgrade,
                &cmd::tasks::Opts {
                    only,
                    skip,
                    dry_run,
                },
            )?;
        }
        Cmd::Install {
            only,
            skip,
            dry_run,
        } => {
            let tools = dot_core::tools::Tools::load(&layers()?)?;
            cmd::install::run(
                &tools.install,
                &cmd::tasks::Opts {
                    only,
                    skip,
                    dry_run,
                },
            )?;
        }
        Cmd::Schema => {
            let dir = dots.join("schemas");
            std::fs::create_dir_all(&dir)?;
            for (name, schema) in [
                ("dot.schema.json", schemars::schema_for!(dot_core::Manifest)),
                (
                    "tools.schema.json",
                    schemars::schema_for!(dot_core::tools::Tools),
                ),
                (
                    "shared.schema.json",
                    schemars::schema_for!(dot_shellgen::Shared),
                ),
                (
                    "profile.schema.json",
                    schemars::schema_for!(dot_core::profile::ProfileMeta),
                ),
            ] {
                let path = dir.join(name);
                std::fs::write(&path, serde_json::to_string_pretty(&schema)? + "\n")?;
                outln!("wrote {}", path.display());
            }
        }
        Cmd::Gen { shell, stdout } => {
            let shells = if shell.is_empty() {
                dot_shellgen::default_shells()
            } else {
                shell
            };
            if stdout {
                use std::io::Write as _;
                let shared = dot_shellgen::Shared::load(&layers()?)?;
                let mut out = std::io::stdout().lock();
                for s in shells {
                    let g = dot_shellgen::generate(&shared, s, &root)?;
                    let mut text = format!("##### {}\n{}\n", s.name(), g.main);
                    if let Some(lazy) = g.lazy {
                        text += &format!("##### {} (lazy)\n{lazy}\n", s.name());
                    }
                    // Closed pipe (e.g. `| head`) is not an error.
                    if out.write_all(text.as_bytes()).is_err() {
                        return Ok(());
                    }
                }
            } else {
                for p in dot_shellgen::generate_all(&layers()?, &shells)? {
                    outln!("wrote {}", p.display());
                }
            }
        }
        Cmd::Prompt { .. }
        | Cmd::Which { .. }
        | Cmd::Link { .. }
        | Cmd::Rollback { .. }
        | Cmd::Colors { .. }
        | Cmd::Reveal { .. }
        | Cmd::Tolf { .. }
        | Cmd::Keyrate { .. } => unreachable!(),
    }
    Ok(())
}

/// `--profile` / `$DOT_PROFILE`, else the profile saved by `dot profile use`.
/// An empty value (`--profile ''`) means no profile: base config only.
fn active_profile(flag: Option<&str>) -> Option<String> {
    match flag {
        Some("") => None,
        Some(name) => Some(name.to_string()),
        None => dot_core::profile::saved(),
    }
}

/// Repo root: an ancestor of `start` with `dots/core/dot.toml`, else the one saved by
/// the last gen/deploy/profile use (`--root` / `$DOT_ROOT` are handled by the caller).
fn find_root(start: &Path) -> Result<PathBuf> {
    start
        .ancestors()
        .find(|d| d.join("dots").join("core").join("dot.toml").is_file())
        .map(Path::to_path_buf)
        .or_else(dot_core::state::saved_root)
        .context(
            "dots/core/dot.toml not found in any parent directory; pass --root or set DOT_ROOT",
        )
}
