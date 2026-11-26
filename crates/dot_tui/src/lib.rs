//! `dot tui`: Links (state / deploy / rollback) and Profiles (switch / where each
//! setting comes from). Rendering is in `ui`, state and actions in `app`.

mod app;
mod ui;

use std::path::Path;

use anyhow::Result;
use ratatui::crossterm::event::{self, Event, KeyCode, KeyEventKind};

pub use app::App;
use app::{Pane, Pending, Tab};

/// Run the TUI until `q`. `root` is the repo root; `active` the active profile.
pub fn run(root: &Path, active: Option<String>) -> Result<()> {
    let mut app = App::new(root, active);
    let mut terminal = ratatui::init(); // also restores the terminal on panic
    let result = (|| -> Result<()> {
        while !app.quit {
            terminal.draw(|f| ui::draw(f, &mut app))?;
            if let Event::Key(key) = event::read()?
                && key.kind == KeyEventKind::Press
            {
                handle_key(&mut app, key.code);
            }
        }
        Ok(())
    })();
    ratatui::restore();
    result
}

pub fn handle_key(app: &mut App, code: KeyCode) {
    // Popups take the key first.
    if app.hover.take().is_some() {
        return; // any key closes the hover
    }
    if let Some(pending) = app.confirm.take() {
        if matches!(code, KeyCode::Char('y') | KeyCode::Char('Y')) {
            app.run_pending(pending);
        } else {
            app.message = "cancelled".into();
        }
        return;
    }
    app.message.clear();

    // `gg`: only when the previous key was `g`.
    let was_g = std::mem::take(&mut app.pending_g);
    match code {
        KeyCode::Char('g') if was_g => return app.jump(true),
        KeyCode::Char('g') => {
            app.pending_g = true;
            return;
        }
        _ => {}
    }

    match code {
        KeyCode::Char('q') | KeyCode::Esc => app.quit = true,
        KeyCode::Tab | KeyCode::BackTab => {
            app.tab = if app.tab == Tab::Links {
                Tab::Profiles
            } else {
                Tab::Links
            };
        }
        KeyCode::Char('1') => app.tab = Tab::Links,
        KeyCode::Char('2') => app.tab = Tab::Profiles,
        KeyCode::Char('r') => {
            app.refresh();
            if app.message.is_empty() {
                app.message = "reloaded".into();
            }
        }
        KeyCode::Char('j') | KeyCode::Down => app.move_by(1),
        KeyCode::Char('k') | KeyCode::Up => app.move_by(-1),
        KeyCode::PageDown => app.move_by(10),
        KeyCode::PageUp => app.move_by(-10),
        KeyCode::Char('G') | KeyCode::End => app.jump(false),
        KeyCode::Home => app.jump(true),
        KeyCode::Char('K') => app.open_hover(),
        _ => match app.tab {
            Tab::Links => links_key(app, code),
            Tab::Profiles => profiles_key(app, code),
        },
    }
}

fn links_key(app: &mut App, code: KeyCode) {
    match code {
        KeyCode::Char('d') | KeyCode::Char('f') if app.pending_changes() == 0 => {
            app.message = "nothing to deploy: every link is ok".into();
        }
        KeyCode::Char('d') => app.confirm = Some(Pending::Deploy { force: false }),
        KeyCode::Char('f') => app.confirm = Some(Pending::Deploy { force: true }),
        KeyCode::Char('u') => app.confirm = Some(Pending::Rollback),
        _ => {}
    }
}

fn profiles_key(app: &mut App, code: KeyCode) {
    match code {
        KeyCode::Char('h') | KeyCode::Left => app.focus = Pane::List,
        KeyCode::Char('l') | KeyCode::Right => app.focus = Pane::Values,
        KeyCode::Char('t') => app.next_file(),
        KeyCode::Enter => {
            if let Some(p) = app.selected_profile() {
                if p.name == app.active {
                    app.message = "already active".into();
                } else {
                    app.confirm = Some(Pending::UseProfile(p.name.clone()));
                }
            }
        }
        _ => {}
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::Terminal;
    use ratatui::backend::TestBackend;

    fn repo_root() -> std::path::PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("..")
            .canonicalize()
            .unwrap()
    }

    fn screen(app: &mut App) -> String {
        let mut t = Terminal::new(TestBackend::new(140, 30)).unwrap();
        t.draw(|f| ui::draw(f, app)).unwrap();
        let buf = t.backend().buffer();
        (0..buf.area.height)
            .map(|y| {
                (0..buf.area.width)
                    .map(|x| buf[(x, y)].symbol())
                    .collect::<String>()
            })
            .collect::<Vec<_>>()
            .join("\n")
    }

    #[test]
    fn renders_both_tabs_and_navigates() {
        let mut app = App::new(&repo_root(), Some("sardonyx".into()));
        assert!(app.message.is_empty(), "load error: {}", app.message);

        let links = screen(&mut app);
        assert!(
            links.contains("1 Links") && links.contains("profile: sardonyx"),
            "{links}"
        );
        assert!(links.contains("git_local"), "profile link listed:\n{links}");

        handle_key(&mut app, KeyCode::Char('2'));
        let profiles = screen(&mut app);
        assert!(
            profiles.contains("(core only)") && profiles.contains("* sardonyx"),
            "{profiles}"
        );
        assert!(
            profiles.contains("profiles/sardonyx"),
            "provenance column:\n{profiles}"
        );

        // Switch file and move to "core only": no profile layer values remain.
        handle_key(&mut app, KeyCode::Char('t'));
        assert!(screen(&mut app).contains("tools.toml"));
        handle_key(&mut app, KeyCode::Char('k'));
        assert!(app.origins.iter().all(|o| o.layer == "core"));

        // Enter asks for confirmation; `n` cancels without touching the saved profile.
        handle_key(&mut app, KeyCode::Enter);
        assert_eq!(app.confirm, Some(Pending::UseProfile(None)));
        assert!(screen(&mut app).contains("Confirm"));
        handle_key(&mut app, KeyCode::Char('n'));
        assert!(app.confirm.is_none() && app.active.as_deref() == Some("sardonyx"));

        handle_key(&mut app, KeyCode::Char('q'));
        assert!(app.quit);
    }

    #[test]
    fn vim_motions_and_hover() {
        let mut app = App::new(&repo_root(), Some("sardonyx".into()));
        let last = app.links.len() - 1;

        handle_key(&mut app, KeyCode::Char('G'));
        assert_eq!(app.link_state.selected(), Some(last));
        handle_key(&mut app, KeyCode::Char('g'));
        handle_key(&mut app, KeyCode::Char('j')); // `g` then `j`: not `gg`
        assert_eq!(app.link_state.selected(), Some(last));
        handle_key(&mut app, KeyCode::Char('g'));
        handle_key(&mut app, KeyCode::Char('g'));
        assert_eq!(app.link_state.selected(), Some(0));

        // K shows the full, untruncated paths; any key closes it.
        handle_key(&mut app, KeyCode::Char('K'));
        let hover = app.hover.clone().expect("hover");
        let first = &app.links[0];
        assert!(
            hover
                .lines
                .iter()
                .any(|l| l.contains(&first.dst.display().to_string()))
        );
        assert!(screen(&mut app).contains("any key: close"));
        handle_key(&mut app, KeyCode::Char('x'));
        assert!(app.hover.is_none() && !app.quit, "closing key is swallowed");

        // Profiles: l focuses the values; K shows the value and its layer.
        handle_key(&mut app, KeyCode::Char('2'));
        handle_key(&mut app, KeyCode::Char('l'));
        handle_key(&mut app, KeyCode::Char('G'));
        assert_eq!(app.origin_state.selected(), Some(app.origins.len() - 1));
        handle_key(&mut app, KeyCode::Char('K'));
        let hover = app.hover.clone().expect("value hover");
        assert!(
            hover.lines.iter().any(|l| l.starts_with("from:")),
            "{hover:?}"
        );
        handle_key(&mut app, KeyCode::Esc);
        assert!(!app.quit, "Esc only closed the hover");
        handle_key(&mut app, KeyCode::Char('h'));
        handle_key(&mut app, KeyCode::Char('K'));
        assert!(
            app.hover
                .as_ref()
                .is_some_and(|h| h.title.starts_with("profile"))
        );
    }
}
