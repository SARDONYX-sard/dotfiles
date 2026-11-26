//! TUI state and the actions behind each key (all real work is in `dot_core`).

use std::path::{Path, PathBuf};

use anyhow::Result;
use dot_core::apply::{self, Options};
use dot_core::config::{self, Origin};
use dot_core::profile::{self, Layers};
use dot_core::{Manifest, Plan, PlanEntry};
use ratatui::widgets::{ListState, TableState};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tab {
    Links,
    Profiles,
}

/// Config files shown in the Profiles tab (relative to each layer root).
pub const FILES: [&str; 3] = ["dot.toml", "tools.toml", "shell/shared.toml"];

/// A row of the profile list; `name: None` = core only.
#[derive(Debug, Clone)]
pub struct ProfileItem {
    pub name: Option<String>,
    pub description: String,
    pub extends: Vec<String>,
}

/// Focused pane of the Profiles tab.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Pane {
    List,
    Values,
}

/// Full text of the selected row (`K`), for values cut off in the table.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Hover {
    pub title: String,
    pub lines: Vec<String>,
}

/// An action waiting for y/n.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Pending {
    Deploy { force: bool },
    Rollback,
    UseProfile(Option<String>),
}

pub struct App {
    pub root: PathBuf,
    pub dots: PathBuf,
    pub active: Option<String>,
    pub tab: Tab,

    pub links: Vec<PlanEntry>,
    pub unmanaged: Vec<(PathBuf, PathBuf)>,
    pub link_state: TableState,

    pub profiles: Vec<ProfileItem>,
    pub profile_state: ListState,
    pub file: usize,
    pub chain: Vec<String>,
    pub origins: Vec<Origin>,
    pub origin_state: TableState,

    pub confirm: Option<Pending>,
    pub focus: Pane,
    /// First `g` of `gg` was pressed.
    pub pending_g: bool,
    pub hover: Option<Hover>,
    pub message: String,
    pub quit: bool,
}

impl App {
    pub fn new(root: &Path, active: Option<String>) -> Self {
        let mut app = Self {
            root: root.to_path_buf(),
            dots: root.join("dots"),
            active,
            tab: Tab::Links,
            links: Vec::new(),
            unmanaged: Vec::new(),
            link_state: TableState::default(),
            profiles: Vec::new(),
            profile_state: ListState::default(),
            file: 0,
            chain: Vec::new(),
            origins: Vec::new(),
            origin_state: TableState::default(),
            confirm: None,
            focus: Pane::List,
            pending_g: false,
            hover: None,
            message: String::new(),
            quit: false,
        };
        app.refresh();
        app
    }

    /// Reload everything; errors go to the message line.
    pub fn refresh(&mut self) {
        if let Err(e) = self.refresh_links().and_then(|()| self.refresh_profiles()) {
            self.message = format!("error: {e:#}");
        }
    }

    fn layers(&self, profile: Option<&str>) -> Result<Layers> {
        Layers::new(&self.dots, profile)
    }

    fn plan(&self) -> Result<Plan> {
        let manifest = Manifest::load(&self.layers(self.active.as_deref())?)?;
        Plan::build(&manifest, &self.root, &self.dots)
    }

    pub fn refresh_links(&mut self) -> Result<()> {
        let plan = self.plan()?;
        self.unmanaged = dot_core::plan::unmanaged_links(&plan, &self.root);
        self.links = plan.entries;
        clamp(&mut self.link_state, self.links.len());
        Ok(())
    }

    pub fn refresh_profiles(&mut self) -> Result<()> {
        let mut items = vec![ProfileItem {
            name: None,
            description: "base config only".into(),
            extends: Vec::new(),
        }];
        for name in profile::list(&self.dots)? {
            let meta = profile::read_meta(&self.dots, &name)?;
            items.push(ProfileItem {
                name: Some(name),
                description: meta.description.unwrap_or_default(),
                extends: meta.extends,
            });
        }
        self.profiles = items;
        if self.profile_state.selected().is_none() {
            let active = self.profiles.iter().position(|p| p.name == self.active);
            self.profile_state.select(Some(active.unwrap_or(0)));
        }
        clamp_list(&mut self.profile_state, self.profiles.len());
        self.refresh_origins()
    }

    pub fn selected_profile(&self) -> Option<&ProfileItem> {
        self.profile_state
            .selected()
            .and_then(|i| self.profiles.get(i))
    }

    /// Effective values of `FILES[file]` for the selected profile, with their layer.
    pub fn refresh_origins(&mut self) -> Result<()> {
        let name = self.selected_profile().and_then(|p| p.name.clone());
        let layers = self.layers(name.as_deref())?;
        self.chain = layers.chain.clone();
        self.origins = config::provenance(&layers.files(FILES[self.file]))?;
        self.origin_state.select(if self.origins.is_empty() {
            None
        } else {
            Some(0)
        });
        Ok(())
    }

    /// Number of links a deploy would change.
    pub fn pending_changes(&self) -> usize {
        self.links
            .iter()
            .filter(|e| e.action != dot_core::Action::Ok)
            .count()
    }

    pub fn run_pending(&mut self, pending: Pending) {
        let result = match pending {
            Pending::Deploy { force } => self.deploy(force),
            Pending::Rollback => self.rollback(),
            Pending::UseProfile(name) => self.use_profile(name),
        };
        if let Err(e) = result {
            self.message = format!("error: {e:#}");
        }
    }

    fn deploy(&mut self, force: bool) -> Result<()> {
        let plan = self.plan()?;
        let report = apply::apply(&plan, &Options::default_paths(force)?)?;
        self.message = format!(
            "deployed: {} changed, {} skipped{}",
            report.changed.len(),
            report.skipped.len(),
            if report.skipped.is_empty() {
                ""
            } else {
                " (conflicts need force: f)"
            }
        );
        self.refresh_links()
    }

    fn rollback(&mut self) -> Result<()> {
        let log = apply::rollback(&Options::default_paths(false)?, false)?;
        self.message = format!("rolled back {} link(s)", log.len());
        self.refresh_links()
    }

    fn use_profile(&mut self, name: Option<String>) -> Result<()> {
        profile::save(name.as_deref())?;
        self.message = match &name {
            Some(n) => format!("active profile: {n} — run `dot gen`, then deploy (d)"),
            None => "profile cleared (core only) — run `dot gen`, then deploy (d)".into(),
        };
        self.active = name;
        self.refresh_links()
    }

    pub fn next_file(&mut self) {
        self.file = (self.file + 1) % FILES.len();
        if let Err(e) = self.refresh_origins() {
            self.message = format!("error: {e:#}");
        }
    }

    pub fn move_profile(&mut self, delta: isize) {
        step_list(&mut self.profile_state, self.profiles.len(), delta);
        if let Err(e) = self.refresh_origins() {
            self.message = format!("error: {e:#}");
        }
    }

    /// Move the selection of the focused list/table (clamped).
    pub fn move_by(&mut self, delta: isize) {
        match (self.tab, self.focus) {
            (Tab::Links, _) => step_table(&mut self.link_state, self.links.len(), delta),
            (Tab::Profiles, Pane::List) => self.move_profile(delta),
            (Tab::Profiles, Pane::Values) => {
                step_table(&mut self.origin_state, self.origins.len(), delta)
            }
        }
    }

    /// `gg` / `G`.
    pub fn jump(&mut self, first: bool) {
        self.move_by(if first {
            isize::MIN / 2
        } else {
            isize::MAX / 2
        });
    }

    /// `K`: full text of the selected row of the focused list/table.
    pub fn open_hover(&mut self) {
        self.hover = match (self.tab, self.focus) {
            (Tab::Links, _) => self
                .link_state
                .selected()
                .and_then(|i| self.links.get(i))
                .map(|e| Hover {
                    title: format!("link [{}]", e.pkg),
                    lines: vec![
                        format!("state: {}", e.action),
                        format!("dst:   {}", e.dst.display()),
                        format!("src:   {}", e.src.display()),
                    ],
                }),
            (Tab::Profiles, Pane::List) => self.selected_profile().map(|p| {
                let name = p.name.clone().unwrap_or_else(|| "(core only)".into());
                let layers = match &p.name {
                    Some(n) => profile::chain(&self.dots, n)
                        .map(|c| format!("core -> {}", c.join(" -> ")))
                        .unwrap_or_else(|e| format!("error: {e:#}")),
                    None => "core".into(),
                };
                Hover {
                    title: format!("profile [{name}]"),
                    lines: vec![
                        format!("description: {}", p.description),
                        format!("extends:     {}", p.extends.join(", ")),
                        format!("layers:      {layers}"),
                        format!(
                            "dir:         {}",
                            p.name
                                .as_deref()
                                .map_or_else(
                                    || profile::core_dir(&self.dots),
                                    |n| profile::profile_dir(&self.dots, n)
                                )
                                .display()
                        ),
                    ],
                }
            }),
            (Tab::Profiles, Pane::Values) => self
                .origin_state
                .selected()
                .and_then(|i| self.origins.get(i))
                .map(|o| Hover {
                    title: format!("{} [{}]", FILES[self.file], o.key),
                    lines: vec![
                        format!("key:   {}", o.key),
                        format!("value: {}", o.value),
                        format!("from:  {}/{}", o.layer, FILES[self.file]),
                    ],
                }),
        };
        if self.hover.is_none() {
            self.message = "nothing selected".into();
        }
    }
}

pub fn step_table(state: &mut TableState, len: usize, delta: isize) {
    if len == 0 {
        return;
    }
    let cur = state.selected().unwrap_or(0) as isize;
    state.select(Some((cur + delta).clamp(0, len as isize - 1) as usize));
}

fn step_list(state: &mut ListState, len: usize, delta: isize) {
    if len == 0 {
        return;
    }
    let cur = state.selected().unwrap_or(0) as isize;
    state.select(Some((cur + delta).clamp(0, len as isize - 1) as usize));
}

fn clamp(state: &mut TableState, len: usize) {
    state.select(match (state.selected(), len) {
        (_, 0) => None,
        (None, _) => Some(0),
        (Some(i), n) => Some(i.min(n - 1)),
    });
}

fn clamp_list(state: &mut ListState, len: usize) {
    state.select(match (state.selected(), len) {
        (_, 0) => None,
        (None, _) => Some(0),
        (Some(i), n) => Some(i.min(n - 1)),
    });
}
