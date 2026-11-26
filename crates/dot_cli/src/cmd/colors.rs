//! `dot colors`: print ANSI color tables to check a terminal theme.

use std::fmt::Write as _;

/// 16 colors: each foreground with bold/underline/blink, on every background.
fn basic() -> String {
    let mut s = String::new();
    for fg in 30..=37 {
        let _ = writeln!(s, "\x1b[{fg}m \\e[{fg}m \x1b[m");
        for mode in [1, 4, 5] {
            for bg in std::iter::once(None).chain((40..=47).map(Some)) {
                let code = match bg {
                    Some(bg) => format!("{fg};{bg};{mode}"),
                    None => format!("{fg};{mode}"),
                };
                let _ = write!(s, "\x1b[{code}m \\e[{code}m \x1b[m");
            }
            s.push('\n');
        }
        s.push('\n');
    }
    s
}

/// 256-color palette as foreground and background, 6 per row.
fn palette() -> String {
    let mut s = String::new();
    for kind in [38, 48] {
        for c in 0..=255u16 {
            let _ = write!(s, "\x1b[{kind};5;{c}m  {c:>3}  \x1b[0m");
            // Rows of 6 aligned to the 6x6x6 color cube (starts at 16).
            if (c + 1) % 6 == 4 {
                s.push('\n');
            }
        }
        s.push('\n');
    }
    s
}

pub fn run(all_256: bool) {
    print!("{}", if all_256 { palette() } else { basic() });
}
