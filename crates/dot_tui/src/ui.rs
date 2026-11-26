//! Rendering. Pure function of `App` (keeps it testable with `TestBackend`).

use std::path::Path;

use dot_core::Action;
use ratatui::Frame;
use ratatui::layout::{Constraint, Flex, Layout, Rect};
use ratatui::style::{Color, Modifier, Style, Stylize};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, Cell, Clear, List, ListItem, Paragraph, Row, Table, Tabs, Wrap};

use crate::app::{App, FILES, Hover, Pane, Pending, Tab};

pub fn draw(f: &mut Frame, app: &mut App) {
    let [header, body, footer] = Layout::vertical([
        Constraint::Length(1),
        Constraint::Min(0),
        Constraint::Length(1),
    ])
    .areas(f.area());

    draw_header(f, app, header);
    match app.tab {
        Tab::Links => draw_links(f, app, body),
        Tab::Profiles => draw_profiles(f, app, body),
    }
    draw_footer(f, app, footer);
    if let Some(p) = &app.confirm {
        draw_confirm(f, app, p);
    }
    if let Some(h) = &app.hover {
        draw_hover(f, h);
    }
}

/// Border of a pane: highlighted when it has the focus.
fn pane(title: String, focused: bool) -> Block<'static> {
    let block = Block::bordered().title(title);
    if focused {
        block.border_style(Style::new().cyan())
    } else {
        block
    }
}

fn draw_header(f: &mut Frame, app: &App, area: Rect) {
    let [tabs, info] = Layout::horizontal([Constraint::Min(0), Constraint::Length(40)]).areas(area);
    let selected = match app.tab {
        Tab::Links => 0,
        Tab::Profiles => 1,
    };
    f.render_widget(
        Tabs::new(["1 Links", "2 Profiles"])
            .select(selected)
            .highlight_style(Style::new().green().bold()),
        tabs,
    );
    let profile = app.active.as_deref().unwrap_or("(core only)");
    f.render_widget(
        Paragraph::new(Line::from(vec![
            "profile: ".dark_gray(),
            profile.cyan().bold(),
        ]))
        .right_aligned(),
        info,
    );
}

fn action_style(a: &Action) -> (String, Color) {
    match a {
        Action::Ok => ("ok".into(), Color::Green),
        Action::Create => ("create".into(), Color::Cyan),
        Action::Relink { .. } => ("relink".into(), Color::Yellow),
        Action::Dangling { .. } => ("dangling".into(), Color::Magenta),
        Action::Conflict { .. } => ("CONFLICT".into(), Color::Red),
        Action::MissingSrc => ("missing src".into(), Color::DarkGray),
    }
}

/// `~` for the home dir, repo-relative for files in the repo.
fn short(p: &Path, root: &Path) -> String {
    if let Ok(rel) = p.strip_prefix(root) {
        return rel.display().to_string();
    }
    match std::env::home_dir().and_then(|h| p.strip_prefix(&h).ok().map(Path::to_path_buf)) {
        Some(rel) => format!("~{}{}", std::path::MAIN_SEPARATOR, rel.display()),
        None => p.display().to_string(),
    }
}

fn draw_links(f: &mut Frame, app: &mut App, area: Rect) {
    let rows = app.links.iter().map(|e| {
        let (label, color) = action_style(&e.action);
        Row::new(vec![
            Cell::from(label).style(Style::new().fg(color)),
            Cell::from(e.pkg.clone()),
            Cell::from(short(&e.dst, &app.root)),
            Cell::from(short(&e.src, &app.root)).style(Style::new().dark_gray()),
        ])
    });
    let unmanaged = if app.unmanaged.is_empty() {
        String::new()
    } else {
        format!(
            " · {} unmanaged link(s) into the repo (prune on deploy)",
            app.unmanaged.len()
        )
    };
    let title = format!(
        " Links: {} total, {} to change{unmanaged} ",
        app.links.len(),
        app.pending_changes()
    );
    let table = Table::new(
        rows,
        [
            Constraint::Length(11),
            Constraint::Length(16),
            Constraint::Percentage(45),
            Constraint::Percentage(55),
        ],
    )
    .header(Row::new(["state", "pkg", "dst", "src"]).style(Style::new().bold().underlined()))
    .block(Block::bordered().title(title))
    .row_highlight_style(Style::new().add_modifier(Modifier::REVERSED));
    f.render_stateful_widget(table, area, &mut app.link_state);
}

fn draw_profiles(f: &mut Frame, app: &mut App, area: Rect) {
    let [left, right] =
        Layout::horizontal([Constraint::Percentage(30), Constraint::Percentage(70)]).areas(area);

    let items: Vec<ListItem> = app
        .profiles
        .iter()
        .map(|p| {
            let active = p.name == app.active;
            let mut spans = vec![
                if active {
                    "* ".green().bold()
                } else {
                    "  ".into()
                },
                Span::from(p.name.clone().unwrap_or_else(|| "(core only)".into())).bold(),
            ];
            if !p.extends.is_empty() {
                spans.push(format!(" <- {}", p.extends.join(", ")).dark_gray());
            }
            let mut lines = vec![Line::from(spans)];
            if !p.description.is_empty() {
                lines.push(Line::from(format!("    {}", p.description)).dark_gray());
            }
            ListItem::new(lines)
        })
        .collect();
    f.render_stateful_widget(
        List::new(items)
            .block(pane(" Profiles ".into(), app.focus == Pane::List))
            .highlight_style(Style::new().add_modifier(Modifier::REVERSED)),
        left,
        &mut app.profile_state,
    );

    let chain = if app.chain.is_empty() {
        String::new()
    } else {
        format!(" -> {}", app.chain.join(" -> "))
    };
    let title = format!(" {} [t] · layers: core{chain} ", FILES[app.file]);
    let rows = app.origins.iter().map(|o| {
        let layer_style = if o.layer == "core" {
            Style::new().dark_gray()
        } else {
            Style::new().cyan()
        };
        Row::new(vec![
            Cell::from(o.key.clone()),
            Cell::from(o.value.clone()),
            Cell::from(o.layer.clone()).style(layer_style),
        ])
    });
    let table = Table::new(
        rows,
        [
            Constraint::Percentage(40),
            Constraint::Percentage(40),
            Constraint::Percentage(20),
        ],
    )
    .header(Row::new(["key", "value", "from"]).style(Style::new().bold().underlined()))
    .block(pane(title, app.focus == Pane::Values))
    .row_highlight_style(Style::new().add_modifier(Modifier::REVERSED));
    f.render_stateful_widget(table, right, &mut app.origin_state);
}

fn draw_footer(f: &mut Frame, app: &App, area: Rect) {
    let line = if !app.message.is_empty() {
        Line::from(app.message.clone().yellow())
    } else {
        let keys = match app.tab {
            Tab::Links => {
                "j/k gg/G move · K full row · d deploy · f --force · u rollback · r reload"
            }
            Tab::Profiles => {
                "h/l pane · j/k gg/G move · K full row · t file · Enter use · r reload"
            }
        };
        Line::from(vec![
            keys.dark_gray(),
            "  ·  Tab/1/2 tabs · q quit".dark_gray(),
        ])
    };
    f.render_widget(Paragraph::new(line), area);
}

fn draw_hover(f: &mut Frame, hover: &Hover) {
    let width = (f.area().width * 4 / 5).max(20);
    // Wrapped line count, roughly: long paths take several rows.
    let inner = width.saturating_sub(2).max(1) as usize;
    let rows: usize = hover
        .lines
        .iter()
        .map(|l| l.chars().count().div_ceil(inner).max(1))
        .sum();
    let area = centered(f.area(), width, (rows as u16 + 4).min(f.area().height));
    let text: Vec<Line> = hover
        .lines
        .iter()
        .map(|l| Line::from(l.clone()))
        .chain([Line::from(""), Line::from("any key: close".dark_gray())])
        .collect();
    f.render_widget(Clear, area);
    f.render_widget(
        Paragraph::new(text).wrap(Wrap { trim: false }).block(
            Block::bordered()
                .title(format!(" {} ", hover.title))
                .border_style(Style::new().cyan()),
        ),
        area,
    );
}

fn draw_confirm(f: &mut Frame, app: &App, pending: &Pending) {
    let text = match pending {
        Pending::Deploy { force: false } => format!(
            "Deploy {} change(s)? Conflicts are skipped.\nUndo later with rollback (u).",
            app.pending_changes()
        ),
        Pending::Deploy { force: true } => format!(
            "Deploy {} change(s) with --force?\nConflicting real files are moved to the backup dir.",
            app.pending_changes()
        ),
        Pending::Rollback => "Roll back the most recent deploy?".into(),
        Pending::UseProfile(name) => format!(
            "Use profile `{}` on this machine?",
            name.as_deref().unwrap_or("(core only)")
        ),
    };
    let area = centered(f.area(), 60, 6);
    f.render_widget(Clear, area);
    f.render_widget(
        Paragraph::new(format!("{text}\n\n[y] yes   [n] no"))
            .wrap(Wrap { trim: false })
            .block(
                Block::bordered()
                    .title(" Confirm ")
                    .border_style(Style::new().yellow()),
            ),
        area,
    );
}

fn centered(area: Rect, width: u16, height: u16) -> Rect {
    let [v] = Layout::vertical([Constraint::Length(height)])
        .flex(Flex::Center)
        .areas(area);
    let [h] = Layout::horizontal([Constraint::Length(width)])
        .flex(Flex::Center)
        .areas(v);
    h
}
