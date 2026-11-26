//! Core of `dot`: manifest loading, path resolution, link planning and applying.

pub mod apply;
pub mod config;
pub mod fsx;
pub mod manifest;
pub mod path;
pub mod plan;
pub mod profile;
pub mod state;
pub mod tools;

pub use manifest::Manifest;
pub use plan::{Action, Plan, PlanEntry};
