//! Kali-style two-line prompt with git / rust info.
//!
//! ```text
//! ┌──[~/dotfiles]─(main ↑1 ↓2 +3 !1 ?2 ≡1 REBASE)─(🦀1.100.0) ✘1 (1.2s) 2026-11-26(Thu) 12:34:56
//! └─$          (`#` in red when admin/root)
//! ```

mod git;
mod rust;
mod style;

use std::path::Path;
use std::time::Duration;

use style::{Color, Painter};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Target {
    /// Wrap escapes in `\x01..\x02` so readline can compute width.
    Bash,
    Plain,
}

#[derive(Debug)]
pub struct Args {
    pub target: Target,
    pub status: i32,
    pub duration_ms: Option<u64>,
    /// Max time for `git status`; on timeout only the branch is shown.
    pub git_timeout: Duration,
    /// Show `#` instead of `$`.
    pub admin: bool,
    /// Only the status line (plus newline): the shell draws the input line itself,
    /// e.g. to show the vi mode (`└I$`) without re-running `dot` on mode changes.
    pub status_only: bool,
}

pub fn render(cwd: &Path, args: &Args) -> String {
    let p = Painter::new(args.target);
    let frame = |s: &str| p.paint(Color::Green, s);
    let mut line = String::new();

    line += &frame("┌──[");
    line += &p.paint(Color::Bold, &short_path(cwd));
    line += &frame("]");

    if let Some(repo) = git::find_repo(cwd) {
        let info = git::status(cwd, &repo, args.git_timeout);
        line += &frame("─(");
        line += &info.render(&p);
        line += &frame(")");
    }

    if let Some(ver) = rust::toolchain(cwd) {
        line += &frame("─(");
        line += &p.paint(Color::Red, &format!("🦀{ver}"));
        line += &frame(")");
    }

    if args.status != 0 {
        line.push(' ');
        line += &p.paint(Color::Red, &format!("✘{}", args.status));
    }

    if let Some(ms) = args.duration_ms {
        line += &p.paint(Color::Cyan, " (");
        line += &p.paint(
            if ms >= 1000 {
                Color::Yellow
            } else {
                Color::Reset
            },
            &fmt_duration(ms),
        );
        line += &p.paint(Color::Cyan, ")");
    }

    line.push(' ');
    line += &p.paint(
        Color::Cyan,
        &jiff::ZonedDateTime::now()
            .strftime("%Y-%m-%d(%a) %H:%M:%S")
            .to_string(),
    );

    line.push('\n');
    if args.status_only {
        return line;
    }
    line += &frame("└─");
    line += &if args.admin {
        p.paint(Color::Red, "# ")
    } else {
        p.paint(Color::Cyan, "$ ")
    };
    line
}

fn short_path(cwd: &Path) -> String {
    let s = cwd.display().to_string();
    match dirs::home_dir() {
        Some(home) => match cwd.strip_prefix(&home) {
            Ok(rest) if rest.as_os_str().is_empty() => "~".into(),
            Ok(rest) => format!("~{}{}", std::path::MAIN_SEPARATOR, rest.display()),
            Err(_) => s,
        },
        None => s,
    }
}

fn fmt_duration(ms: u64) -> String {
    match ms {
        0..1_000 => format!("{ms}ms"),
        1_000..60_000 => format!("{:.1}s", ms as f64 / 1000.0),
        _ => format!("{}m{}s", ms / 60_000, (ms % 60_000) / 1000),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn duration() {
        assert_eq!(fmt_duration(523), "523ms");
        assert_eq!(fmt_duration(1234), "1.2s");
        assert_eq!(fmt_duration(125_000), "2m5s");
    }
}
