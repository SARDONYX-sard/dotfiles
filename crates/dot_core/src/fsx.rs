//! Cross-platform symlink helpers.

use std::io;
use std::path::Path;

/// Create `link` pointing at `target`. On Windows the link kind (file/dir) must
/// match the target, so `dir` is required. Needs Developer Mode or admin there.
pub fn symlink(target: &Path, link: &Path, dir: bool) -> io::Result<()> {
    #[cfg(windows)]
    {
        if dir {
            std::os::windows::fs::symlink_dir(target, link)
        } else {
            std::os::windows::fs::symlink_file(target, link)
        }
    }
    #[cfg(not(windows))]
    {
        let _ = dir;
        std::os::unix::fs::symlink(target, link)
    }
}

/// Remove a symlink itself (never what it points to).
pub fn remove_symlink(link: &Path) -> io::Result<()> {
    let meta = std::fs::symlink_metadata(link)?;
    if !meta.file_type().is_symlink() {
        return Err(io::Error::other(format!(
            "{} is not a symlink",
            link.display()
        )));
    }
    #[cfg(windows)]
    {
        use std::os::windows::fs::FileTypeExt as _;
        // Directory symlinks/junctions are removed with RemoveDirectory, which
        // deletes only the link.
        if meta.file_type().is_symlink_dir() {
            return std::fs::remove_dir(link);
        }
    }
    std::fs::remove_file(link)
}

/// Whether an existing symlink is a directory link (Windows distinguishes them).
pub fn is_dir_link(link: &Path) -> bool {
    #[cfg(windows)]
    {
        use std::os::windows::fs::FileTypeExt as _;
        std::fs::symlink_metadata(link).is_ok_and(|m| m.file_type().is_symlink_dir())
    }
    #[cfg(not(windows))]
    {
        std::fs::metadata(link).is_ok_and(|m| m.is_dir())
    }
}
