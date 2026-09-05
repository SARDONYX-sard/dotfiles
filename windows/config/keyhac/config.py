"""Keyhac 2 configuration.

Original v1 configuration migrated to Keyhac 2.
"""

import subprocess

from keyhac import (
    getLogger,
    InputText,
    Keymap,
    KeyTable,
    MouseButtonDown,
    MouseButtonUp,
    MouseMove,
    MoveWindow,
    PlaybackRecordedKeys,
    StartRecordingKeys,
    StopRecordingKeys,
    ToggleRecordingKeys,
)


# Since these definitions were lost in keyhac v2, we'll need to define them ourself.
VK_OEM_1 = 186
VK_OEM_PLUS = 187
VK_OEM_MINUS = 189
VK_OEM_3 = 192
VK_OEM_4 = 219
VK_OEM_5 = 220
VK_OEM_6 = 221
VK_OEM_7 = 222
VK_OEM_102 = 226

# 全角
VK_OEM_AUTO = 243
# 半角
VK_OEM_ENLW = 244


logger = getLogger("Config")


def configure(keymap: Keymap):
    """Configure Keyhac.

    Args:
        keymap: Keyhac keymap instance.
    """
    is_win = keymap.platform == "windows"
    keymap.editor = "nvim.exe" if is_win else "nvim"

    # ------------------------------------------------------------------
    # Keep the original RShift -> User0 mapping on Windows. macOS has Fn as a usable modifier.
    if is_win:
        keymap.replace_key("RShift", 235)
        keymap.define_modifier(235, "User0")

    # Windows-only commands
    keymap_global = keymap.define_keytable(focus_path_pattern="*")

    if is_win:
        cmd_keymap(keymap_global, keymap)

    # Global key bindings
    input_keymap(keymap_global)
    jis_to_us_keyboard(keymap_global)
    macro_key(keymap_global)
    turn_off_clipboard(keymap)
    vim_keybinding(keymap_global)
    virtual_mouse(keymap_global)
    window_moving(keymap_global)


# ============================================================================


def jis_to_us_keyboard(keymap_global: KeyTable):
    """Replace JIS keyboard output with US keyboard layout behavior."""

    keymap_global["Shift-2"] = f"{VK_OEM_3}"  # to @
    keymap_global["Shift-6"] = f"{VK_OEM_7}"  # to ^
    keymap_global["Shift-7"] = "Shift-6"  # to &
    keymap_global["Shift-8"] = f"Shift-{VK_OEM_1}"  # to *
    keymap_global["Shift-9"] = "Shift-8"  # ) to (
    keymap_global["Shift-0"] = "Shift-9"  # to )
    keymap_global[f"Shift-{VK_OEM_MINUS}"] = f"Shift-{VK_OEM_102}"  # = to _
    keymap_global[f"{VK_OEM_7}"] = f"Shift-{VK_OEM_MINUS}"  # ^ to =
    keymap_global[f"Shift-{VK_OEM_7}"] = f"Shift-{VK_OEM_PLUS}"  # ~ to +

    keymap_global[f"({VK_OEM_AUTO})"] = f"Shift-{VK_OEM_3}"  # 半角/全角 to `
    keymap_global[f"({VK_OEM_ENLW})"] = f"Shift-{VK_OEM_3}"  # 半角/全角 to `

    keymap_global[f"Shift-({VK_OEM_AUTO})"] = f"Shift-{VK_OEM_7}"  # shift-半角 to ~
    keymap_global[f"Shift-({VK_OEM_ENLW})"] = f"Shift-{VK_OEM_7}"  # shift-半角 to ~

    keymap_global[f"{VK_OEM_3}"] = f"{VK_OEM_4}"  # @ to [
    keymap_global[f"{VK_OEM_4}"] = f"{VK_OEM_6}"  # to ]
    keymap_global[f"Shift-{VK_OEM_3}"] = f"Shift-{VK_OEM_4}"  # to {
    keymap_global[f"Shift-{VK_OEM_4}"] = f"Shift-{VK_OEM_6}"  # to }

    keymap_global[f"Shift-{VK_OEM_PLUS}"] = f"{VK_OEM_1}"  # + to :
    keymap_global[f"{VK_OEM_1}"] = "Shift-7"  # : to '
    keymap_global[f"Shift-{VK_OEM_1}"] = "Shift-2"  # shift-: to "

    keymap_global[f"{VK_OEM_6}"] = f"{VK_OEM_102}"  # ] to \
    keymap_global[f"Shift-{VK_OEM_6}"] = f"Shift-{VK_OEM_5}"  # shift-] to |


def vim_keybinding(keymap_global: KeyTable):
    """Install Vim-like key bindings.

    Args:
        keymap_global: Global key table.
    """

    keymap_global["LShift-Alt-H"] = "Left"
    keymap_global["LShift-Alt-J"] = "Down"
    keymap_global["LShift-Alt-K"] = "Up"
    keymap_global["LShift-Alt-L"] = "Right"

    keymap_global["LCtrl-H"] = "Back"
    keymap_global["LCtrl-M"] = "Enter"
    keymap_global[f"LCtrl-{VK_OEM_3}"] = "Escape"


def window_moving(keymap_global: KeyTable):
    """Move the active window to screen edges.

    Args:
        keymap_global: Global key table.
    """

    keymap_global["U0-C-A"] = MoveWindow(
        direction="left",
        distance=9999,
        window_edge=True,
        screen_edge=True,
    )

    keymap_global["U0-C-D"] = MoveWindow(
        direction="right",
        distance=9999,
        window_edge=True,
        screen_edge=True,
    )

    keymap_global["U0-C-W"] = MoveWindow(
        direction="up",
        distance=9999,
        window_edge=True,
        screen_edge=True,
    )

    keymap_global["U0-C-S"] = MoveWindow(
        direction="down",
        distance=9999,
        window_edge=True,
        screen_edge=True,
    )


def macro_key(keymap_global: KeyTable):
    """Install keyboard macro bindings.

    Args:
        keymap_global: Global key table.
    """

    keymap_global["U0-0"] = ToggleRecordingKeys()
    keymap_global["U0-1"] = StartRecordingKeys()
    keymap_global["U0-2"] = StopRecordingKeys()
    keymap_global["U0-3"] = PlaybackRecordedKeys()

    # Keyhac 2 does not expose a RecordClear action.
    # The old U0-4 binding is therefore intentionally removed.


def virtual_mouse(keymap_global: KeyTable):
    """Control the mouse using User0.

    Args:
        keymap_global: Global key table.
    """

    keymap_global["U0-Left"] = MouseMove(-10, 0)
    keymap_global["U0-Right"] = MouseMove(10, 0)
    keymap_global["U0-Up"] = MouseMove(0, -10)
    keymap_global["U0-Down"] = MouseMove(0, 10)

    keymap_global["D-U0-Space"] = MouseButtonDown("left")
    keymap_global["U-U0-Space"] = MouseButtonUp("left")


def cmd_keymap(keymap_global: KeyTable, keymap: Keymap):
    """Install Windows-specific commands.

    Args:
        keymap_global: Global key table.
        keymap: Keyhac keymap instance.
    """

    def shutdown():
        """Shut down Windows.

        Raises:
            OSError: If the shutdown command cannot be started.
        """
        subprocess.Popen(["shutdown", "-s"])

    def sleep():
        """Suspend Windows.

        Raises:
            OSError: If PowerShell cannot be started.
        """
        subprocess.Popen(
            [
                "powershell.exe",
                "-NoProfile",
                "-Command",
                (
                    "Add-Type -Assembly System.Windows.Forms;"
                    "[System.Windows.Forms.Application]"
                    "::SetSuspendState('Suspend', $false, $false);"
                ),
            ]
        )

    def clear_trash():
        """Clear the Windows recycle bin.

        Raises:
            OSError: If PowerShell cannot be started.
        """
        subprocess.Popen(
            [
                "powershell.exe",
                "-NoProfile",
                "-Command",
                "Clear-RecycleBin -Force",
            ]
        )

    def close():
        """Close the active window."""
        with keymap.get_input_context() as ctx:
            ctx.send_key("Alt-F4")

    def win_terminal_as_admin():
        """Launch Windows Terminal through sudo.

        Raises:
            OSError: If sudo cannot be started.
        """
        subprocess.Popen(["sudo", "wt.exe"])

    def open_task_manager():
        """Open Windows Task Manager."""
        with keymap.get_input_context() as ctx:
            ctx.send_key("LCtrl-LShift-Escape")

    keymap_global["U0-C"] = close
    keymap_global["U0-Pause"] = shutdown
    keymap_global["U0-Period"] = open_task_manager
    keymap_global["U0-ScrollLock"] = sleep
    keymap_global["U0-Shift-T"] = win_terminal_as_admin
    keymap_global["U0-Slash"] = clear_trash


def input_keymap(keymap_global: KeyTable):
    """Install text insertion bindings.

    Args:
        keymap_global: Global key table.
    """

    keymap_global["U0-S"] = InputText("scoop search ")
    keymap_global["U0-A"] = InputText("update-all-libs")
    keymap_global["U0-D"] = InputText("…（´・ω・｀）")
    keymap_global["U0-F"] = InputText(" --help")
    keymap_global["U0-W"] = InputText("ほう…（´・ω・｀）?")


def turn_off_clipboard(keymap: Keymap):
    """Disable persistent clipboard storage."""

    keymap.clipboard_history.persist = False
    keymap.clipboard_history.max_items = 0
