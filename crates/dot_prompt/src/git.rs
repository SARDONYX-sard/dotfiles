//! Git segment via a single `git status --porcelain=v2 --branch --show-stash`.

use std::io::Read as _;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::sync::mpsc;
use std::time::Duration;

use crate::style::{Color, Painter};

pub struct Repo {
    /// The real git dir (resolves `gitdir:` files used by worktrees/submodules).
    git_dir: PathBuf,
}

/// Walk up from `cwd` looking for `.git` without spawning git.
pub fn find_repo(cwd: &Path) -> Option<Repo> {
    cwd.ancestors().find_map(|dir| {
        let dot_git = dir.join(".git");
        if dot_git.is_dir() {
            return Some(Repo { git_dir: dot_git });
        }
        let text = std::fs::read_to_string(&dot_git).ok()?;
        let rel = text.strip_prefix("gitdir:")?.trim();
        Some(Repo {
            git_dir: dir.join(rel),
        })
    })
}

#[derive(Default)]
pub struct Info {
    branch: String,
    ahead: u32,
    behind: u32,
    staged: u32,
    modified: u32,
    untracked: u32,
    conflicted: u32,
    stash: u32,
    state: Option<&'static str>,
    timed_out: bool,
}

pub fn status(cwd: &Path, repo: &Repo, timeout: Duration) -> Info {
    let mut info = Info {
        state: state(&repo.git_dir),
        ..Default::default()
    };
    match run_status(cwd, timeout) {
        Some(out) => parse(&out, &mut info),
        None => {
            info.timed_out = true;
            info.branch = head_branch(&repo.git_dir).unwrap_or_else(|| "?".into());
        }
    }
    info
}

/// Resolve the git binary. `$DOT_GIT` overrides.
///
/// - Windows: skip wrappers that cost ~60ms per spawn: scoop shims
///   (`shims\git.exe` + `git.shim`) and Git for Windows' `cmd\git.exe`.
/// - WSL under `/mnt/*`: Linux git over the Windows filesystem is ~20x slower
///   (3.2s vs 0.16s measured), so use Windows' `git.exe` via interop.
fn git_bin(cwd: &Path) -> PathBuf {
    if let Some(p) = std::env::var_os("DOT_GIT") {
        return p.into();
    }
    let find_in_path = |name: &str| {
        std::env::var_os("PATH").and_then(|p| {
            std::env::split_paths(&p)
                .map(|d| d.join(name))
                .find(|p| p.is_file())
        })
    };
    if !cfg!(windows) {
        let wsl = std::env::var_os("WSL_DISTRO_NAME").is_some();
        if wsl
            && cwd.starts_with("/mnt")
            && let Some(exe) = find_in_path("git.exe")
        {
            return exe;
        }
        return "git".into();
    }
    let Some(found) = find_in_path("git.exe") else {
        return "git".into();
    };

    let target = std::fs::read_to_string(found.with_extension("shim"))
        .ok()
        .and_then(|s| {
            s.lines().find_map(|l| {
                let v = l
                    .trim()
                    .strip_prefix("path")?
                    .trim_start()
                    .strip_prefix('=')?;
                Some(PathBuf::from(v.trim().trim_matches('"')))
            })
        })
        .unwrap_or(found);

    // <root>\cmd\git.exe -> <root>\{ucrt64,mingw64}\bin\git.exe
    if let Some(root) = target
        .parent()
        .filter(|d| d.ends_with("cmd"))
        .and_then(Path::parent)
    {
        for sub in ["ucrt64", "mingw64", "clangarm64"] {
            let real = root.join(sub).join("bin").join("git.exe");
            if real.is_file() {
                return real;
            }
        }
    }
    target
}

fn run_status(cwd: &Path, timeout: Duration) -> Option<String> {
    let mut child = Command::new(git_bin(cwd))
        .args([
            "--no-optional-locks",
            "status",
            "--porcelain=v2",
            "--branch",
            "--show-stash",
        ])
        .current_dir(cwd)
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .ok()?;

    // Read stdout on a thread; EOF means the child closed its end (normally on exit).
    // `recv_timeout` avoids sleep polling (Windows sleep granularity is ~15ms).
    let mut stdout = child.stdout.take()?;
    let (tx, rx) = mpsc::channel();
    std::thread::spawn(move || {
        let mut s = String::new();
        let _ = tx.send(stdout.read_to_string(&mut s).ok().map(|_| s));
    });

    match rx.recv_timeout(timeout) {
        Ok(out) => child.wait().ok().filter(|st| st.success()).and(out),
        Err(_) => {
            let _ = child.kill();
            let _ = child.wait();
            None
        }
    }
}

fn parse(out: &str, info: &mut Info) {
    let mut oid = "";
    for line in out.lines() {
        if let Some(h) = line.strip_prefix("# branch.head ") {
            info.branch = h.to_string();
        } else if let Some(o) = line.strip_prefix("# branch.oid ") {
            oid = o;
        } else if let Some(ab) = line.strip_prefix("# branch.ab ") {
            let mut it = ab.split(' ');
            info.ahead = it
                .next()
                .and_then(|s| s.trim_start_matches('+').parse().ok())
                .unwrap_or(0);
            info.behind = it
                .next()
                .and_then(|s| s.trim_start_matches('-').parse().ok())
                .unwrap_or(0);
        } else if let Some(n) = line.strip_prefix("# stash ") {
            info.stash = n.parse().unwrap_or(0);
        } else if let Some(rest) = line.strip_prefix("1 ").or_else(|| line.strip_prefix("2 ")) {
            let xy = rest.as_bytes();
            if xy.first().is_some_and(|&c| c != b'.') {
                info.staged += 1;
            }
            if xy.get(1).is_some_and(|&c| c != b'.') {
                info.modified += 1;
            }
        } else if line.starts_with("u ") {
            info.conflicted += 1;
        } else if line.starts_with("? ") {
            info.untracked += 1;
        }
    }
    if info.branch == "(detached)" {
        info.branch = format!("@{}", oid.get(..7).unwrap_or(oid));
    }
}

fn head_branch(git_dir: &Path) -> Option<String> {
    let head = std::fs::read_to_string(git_dir.join("HEAD")).ok()?;
    Some(match head.trim().strip_prefix("ref: refs/heads/") {
        Some(b) => b.to_string(),
        None => format!("@{}", head.get(..7)?),
    })
}

fn state(git_dir: &Path) -> Option<&'static str> {
    [
        ("rebase-merge", "REBASE"),
        ("rebase-apply", "REBASE"),
        ("MERGE_HEAD", "MERGE"),
        ("CHERRY_PICK_HEAD", "PICK"),
        ("REVERT_HEAD", "REVERT"),
        ("BISECT_LOG", "BISECT"),
    ]
    .into_iter()
    .find(|(f, _)| git_dir.join(f).exists())
    .map(|(_, s)| s)
}

impl Info {
    pub fn render(&self, p: &Painter) -> String {
        let mut s = p.paint(Color::Magenta, &self.branch);
        let mut seg = |c: Color, sym: &str, n: u32| {
            if n > 0 {
                s.push(' ');
                s += &p.paint(c, &format!("{sym}{n}"));
            }
        };
        seg(Color::Green, "↑", self.ahead);
        seg(Color::Red, "↓", self.behind);
        seg(Color::Green, "+", self.staged);
        seg(Color::Yellow, "!", self.modified);
        seg(Color::Red, "=", self.conflicted);
        seg(Color::Blue, "?", self.untracked);
        seg(Color::Cyan, "≡", self.stash);
        if let Some(st) = self.state {
            s.push(' ');
            s += &p.paint(Color::Red, st);
        }
        if self.timed_out {
            s += &p.paint(Color::Yellow, " …");
        }
        s
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_porcelain_v2() {
        let out = "\
# branch.oid 1234567890abcdef
# branch.head main
# branch.upstream origin/main
# branch.ab +2 -1
# stash 3
1 M. N... 100644 100644 100644 a b f1
1 .M N... 100644 100644 100644 a b f2
1 MM N... 100644 100644 100644 a b f3
u UU N... 1 2 3 4 a b c f4
? new.txt
";
        let mut i = Info::default();
        parse(out, &mut i);
        assert_eq!(i.branch, "main");
        assert_eq!((i.ahead, i.behind, i.stash), (2, 1, 3));
        assert_eq!(
            (i.staged, i.modified, i.conflicted, i.untracked),
            (2, 2, 1, 1)
        );
    }

    #[test]
    fn detached() {
        let mut i = Info::default();
        parse(
            "# branch.oid 1234567890abcdef\n# branch.head (detached)\n",
            &mut i,
        );
        assert_eq!(i.branch, "@1234567");
    }
}
