//! deploy -> re-plan -> rollback round trip in a temp directory.

use std::fs;
use std::path::{Path, PathBuf};

use dot_core::apply::{self, Options};
use dot_core::{Action, Manifest, Plan};

fn tmp(name: &str) -> PathBuf {
    let d = std::env::temp_dir().join(format!("dot-apply-{name}-{}", std::process::id()));
    let _ = fs::remove_dir_all(&d);
    fs::create_dir_all(&d).unwrap();
    d
}

fn action_of<'a>(plan: &'a Plan, dst: &Path) -> &'a Action {
    &plan.entries.iter().find(|e| e.dst == dst).unwrap().action
}

#[test]
fn deploy_and_rollback() {
    let root = tmp("rt");
    let repo = root.join("repo");
    let dots = repo.join("dots");
    let home = root.join("home");
    fs::create_dir_all(dots.join("dir")).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::write(dots.join("a.txt"), "new").unwrap();
    fs::write(dots.join("dir").join("x"), "x").unwrap();
    fs::write(repo.join("old.txt"), "old").unwrap();

    let create = home.join("sub").join("create.txt");
    let relink = home.join("relink.txt");
    let conflict = home.join("conflict.txt");
    let dirlink = home.join("dirlink");
    dot_core::fsx::symlink(&repo.join("old.txt"), &relink, false).unwrap();
    fs::write(&conflict, "mine").unwrap();

    let manifest: Manifest = toml::from_str(&format!(
        r#"
        [pkg.t]
        link = [
          {{ src = "a.txt", dst = '{}' }},
          {{ src = "a.txt", dst = '{}' }},
          {{ src = "a.txt", dst = '{}' }},
          {{ src = "dir",   dst = '{}' }},
        ]
        "#,
        create.display(),
        relink.display(),
        conflict.display(),
        dirlink.display()
    ))
    .unwrap();

    let plan = Plan::build(&manifest, &repo, &dots).unwrap();
    assert_eq!(action_of(&plan, &create), &Action::Create);
    assert!(matches!(action_of(&plan, &relink), Action::Relink { .. }));
    assert!(matches!(
        action_of(&plan, &conflict),
        Action::Conflict { .. }
    ));

    let state_dir = root.join("state");
    let pruned = home.join("stale.txt");
    dot_core::fsx::symlink(&repo.join("old.txt"), &pruned, false).unwrap();
    let opts = |force| Options {
        force,
        prune: if force { vec![pruned.clone()] } else { vec![] },
        state_path: state_dir.join("state.json"),
        backup_dir: state_dir.join("backup"),
    };

    // Without --force the conflict is left alone.
    let report = apply::apply(&plan, &opts(false)).unwrap();
    assert_eq!(report.changed.len(), 3);
    assert_eq!(fs::read_to_string(&conflict).unwrap(), "mine");
    apply::rollback(&opts(false), false).unwrap();

    // With --force everything is linked.
    let report = apply::apply(&plan, &opts(true)).unwrap();
    assert_eq!(report.changed.len(), 5);
    assert!(
        fs::symlink_metadata(&pruned).is_err(),
        "pruned link removed"
    );
    let script = report
        .restore_script
        .clone()
        .expect("restore script written");
    for dst in [&create, &relink, &conflict] {
        assert_eq!(fs::read_to_string(dst).unwrap(), "new");
    }
    assert_eq!(fs::read_to_string(dirlink.join("x")).unwrap(), "x");

    // Idempotent: a second plan is all Ok.
    let again = Plan::build(&manifest, &repo, &dots).unwrap();
    assert!(
        again.entries.iter().all(|e| e.action == Action::Ok),
        "{again:?}"
    );

    // Rollback restores the previous world.
    apply::rollback(&opts(true), false).unwrap();
    assert!(fs::symlink_metadata(&create).is_err());
    assert!(fs::symlink_metadata(&dirlink).is_err());
    assert_eq!(fs::read_link(&relink).unwrap(), repo.join("old.txt"));
    assert_eq!(fs::read_to_string(&conflict).unwrap(), "mine");
    assert!(
        !fs::symlink_metadata(&conflict)
            .unwrap()
            .file_type()
            .is_symlink()
    );
    assert_eq!(fs::read_link(&pruned).unwrap(), repo.join("old.txt"));
    assert!(
        apply::rollback(&opts(true), false).is_err(),
        "history should be empty"
    );

    // The standalone restore script must give the same result as rollback.
    let report = apply::apply(&plan, &opts(true)).unwrap();
    let script2 = report.restore_script.unwrap();
    assert_ne!(script, script2);
    let status = if cfg!(windows) {
        std::process::Command::new("pwsh")
            .args(["-NoProfile", "-File"])
            .arg(&script2)
            .status()
    } else {
        std::process::Command::new("sh").arg(&script2).status()
    };
    if let Ok(st) = status {
        assert!(st.success(), "restore script failed");
        assert!(fs::symlink_metadata(&create).is_err());
        assert!(fs::symlink_metadata(&dirlink).is_err());
        assert_eq!(fs::read_link(&relink).unwrap(), repo.join("old.txt"));
        assert_eq!(fs::read_link(&pruned).unwrap(), repo.join("old.txt"));
        assert_eq!(fs::read_to_string(&conflict).unwrap(), "mine");
    }

    fs::remove_dir_all(&root).unwrap();
}
