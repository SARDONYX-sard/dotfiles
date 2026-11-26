//! Layered TOML configs: `dots/core` -> profiles (parents first).
//!
//! Tables merge recursively; any other value (including arrays) is replaced by the
//! later layer. See [`crate::profile::Layers`] for which files make up the layers.
//!
//! ```toml
//! # dots/profiles/<name>/dot.toml: this profile does not use nushell
//! [pkg.nu]
//! enabled = false
//! ```

use std::path::{Path, PathBuf};

use anyhow::{Context as _, Result};
use serde::de::DeserializeOwned;

/// One file of a layered config.
#[derive(Debug, Clone)]
pub struct Layer {
    pub path: PathBuf,
    /// Root of this layer relative to `dots/` (`core` or `profiles/<name>`); paths
    /// written in the layer are relative to it and get rebased onto `dots/`.
    pub dir: String,
}

/// Merge all existing layers in order and deserialize. `rebase` is called on each
/// layer (with its `dir`) before merging. `None` if no layer exists.
pub fn load_layers<T: DeserializeOwned>(
    layers: &[Layer],
    rebase: impl Fn(&mut toml::Table, &str),
) -> Result<Option<T>> {
    let mut merged: Option<toml::Table> = None;
    for layer in layers {
        let Some(mut table) = read_table(&layer.path)? else {
            continue;
        };
        rebase(&mut table, &layer.dir);
        match &mut merged {
            Some(base) => merge(base, table),
            None => merged = Some(table),
        }
    }
    let Some(table) = merged else { return Ok(None) };
    let files = layers
        .iter()
        .map(|l| l.path.display().to_string())
        .collect::<Vec<_>>();
    toml::Value::Table(table)
        .try_into()
        .map(Some)
        .with_context(|| format!("invalid config (layers: {})", files.join(", ")))
}

fn read_table(path: &Path) -> Result<Option<toml::Table>> {
    match std::fs::read_to_string(path) {
        Ok(text) => {
            Ok(Some(text.parse::<toml::Table>().with_context(|| {
                format!("failed to parse {}", path.display())
            })?))
        }
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(None),
        Err(e) => Err(e).with_context(|| format!("failed to read {}", path.display())),
    }
}

/// One effective value of a layered config and the layer it came from.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Origin {
    /// Dotted key path, e.g. `pkg.nu.enabled` (arrays are leaves, like in `merge`).
    pub key: String,
    /// The value as TOML.
    pub value: String,
    /// `core` or `profiles/<name>`.
    pub layer: String,
}

/// Effective values of `layers` (same merge rules as [`load_layers`]) with the
/// layer each one comes from, in first-defined order.
pub fn provenance(layers: &[Layer]) -> Result<Vec<Origin>> {
    fn flatten(
        table: &toml::Table,
        prefix: &str,
        layer: &str,
        out: &mut indexmap::IndexMap<String, Origin>,
    ) {
        for (k, v) in table {
            let key = if prefix.is_empty() {
                k.clone()
            } else {
                format!("{prefix}.{k}")
            };
            match v {
                toml::Value::Table(t) => flatten(t, &key, layer, out),
                other => {
                    // A table replaced by a value (or vice versa) drops the old leaves.
                    let child = format!("{key}.");
                    out.retain(|existing, _| !existing.starts_with(&child));
                    out.insert(
                        key.clone(),
                        Origin {
                            key,
                            value: other.to_string(),
                            layer: layer.to_string(),
                        },
                    );
                }
            }
        }
    }
    let mut out = indexmap::IndexMap::new();
    for layer in layers {
        if let Some(table) = read_table(&layer.path)? {
            flatten(&table, "", &layer.dir, &mut out);
        }
    }
    Ok(out.into_values().collect())
}

/// Recursively merge `over` into `base`.
pub fn merge(base: &mut toml::Table, over: toml::Table) {
    for (k, v) in over {
        match (base.get_mut(&k), v) {
            (Some(toml::Value::Table(b)), toml::Value::Table(o)) => merge(b, o),
            (_, v) => {
                base.insert(k, v);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn provenance_tracks_overriding_layer() {
        let dir = std::env::temp_dir().join(format!("dot-prov-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let core = dir.join("core.toml");
        let prof = dir.join("prof.toml");
        std::fs::write(
            &core,
            "[env]\nA = \"1\"\nB = \"2\"\n[pkg.x]\nos = [\"linux\"]\n",
        )
        .unwrap();
        std::fs::write(
            &prof,
            "[env]\nB = \"3\"\n[pkg.x]\nos = [\"windows\"]\n[keyrate]\ndelay_ms = 9\n",
        )
        .unwrap();
        let layers = [
            Layer {
                path: core,
                dir: "core".into(),
            },
            Layer {
                path: prof,
                dir: "profiles/p".into(),
            },
        ];
        let got: Vec<_> = provenance(&layers)
            .unwrap()
            .into_iter()
            .map(|o| format!("{}={} @{}", o.key, o.value, o.layer))
            .collect();
        assert_eq!(
            got,
            [
                r#"env.A="1" @core"#,
                r#"env.B="3" @profiles/p"#,
                r#"pkg.x.os=["windows"] @profiles/p"#,
                "keyrate.delay_ms=9 @profiles/p",
            ]
        );
        std::fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn merges_tables_and_replaces_values() {
        let mut base: toml::Table = r#"
            [pkg.nu]
            os = ["windows"]
            [[pkg.nu.link]]
            src = "a"
            dst = "b"
            [pkg.git]
            "#
        .parse()
        .unwrap();
        let over: toml::Table = "[pkg.nu]\nenabled = false\nos = []\n[pkg.extra]\n"
            .parse()
            .unwrap();
        merge(&mut base, over);
        let nu = base["pkg"]["nu"].as_table().unwrap();
        assert_eq!(nu["enabled"].as_bool(), Some(false), "added");
        assert_eq!(nu["os"].as_array().unwrap().len(), 0, "replaced");
        assert_eq!(nu["link"].as_array().unwrap().len(), 1, "kept");
        assert!(base["pkg"].get("git").is_some() && base["pkg"].get("extra").is_some());
    }
}
