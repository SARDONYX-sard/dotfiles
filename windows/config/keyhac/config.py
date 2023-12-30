"""KeyHac config

https://sites.google.com/site/craftware/
"""

import os
from typing import Callable, Dict, Union

# pyauto  ref: (https://github.com/crftwr/pyauto/blob/master/doc/pyauto.py)
# import pyauto
from keyhac import shellExecute, cblister_FixedPhrase, Keymap
from keyhac import (
    VK_OEM_1,
    VK_OEM_102,
    VK_OEM_6,
    VK_OEM_3,
    VK_OEM_4,
    VK_OEM_5,
    VK_OEM_7,
    VK_OEM_PLUS,
    VK_OEM_MINUS,
)

KeymapPair = Dict[str, Union[str, Callable[[], None], Callable[[], str]]]


def configure(keymap: Keymap):
    keymap_global = keymap.defineWindowKeymap()
    keymap.quote_mark = "> "
    keymap.defineModifier(235, "User0")  # User modifier key definition
    keymap.replaceKey("RShift", 235)  # Simple key replacement

    keymap.editor = "nvim.exe" if os.name == "nt" else "nvim"
    keymap.setFont("MS Gothic", 12)
    keymap.setTheme("black")

    is_win = os.name == "nt"
    if is_win:
        cmd_keymap(keymap_global, keymap)

    input_keymap(keymap_global, keymap)
    jis_to_us_keyboard(keymap_global)
    macro_key(keymap_global, keymap)
    show_app_list(keymap_global, keymap)
    turn_off_clipboard(keymap)
    vim_keybinding(keymap_global)
    virtual_mouse(keymap_global, keymap)
    window_moving(keymap_global, keymap)


def show_app_list(keymap_global: KeymapPair, keymap: Keymap):
    """USER0-Space : Application launcher using custom list window"""

    def command_pop_application_list():
        # For toggle window.
        if keymap.isListWindowOpened():
            keymap.cancelListWindow()
            return

        def pop_application_list():
            is_win = os.name == "nt"
            # config
            dl_dir = "E:\\ダウンロード"

            shell = keymap.ShellExecuteCommand

            def win_shell(proc: str):
                return shell(None, proc, "", "") if is_win else None

            apps = [
                ("-- Editor --", win_shell("neovide")),
                ("Vim", win_shell("gvim")),
                ("Neovide", win_shell("neovide")),
                ("Notepad", win_shell("notepad.exe")),
                ("VSCode", shell(None, "code", "", "")),
                #
                (
                    "-- Explorer --",
                    shell(None, "explorer.exe", dl_dir, "") if is_win else None,
                ),
                #
                ("-- Web --", shell(None, "https://www.google.com/", "", "")),
                ("Twitter", shell(None, "https://twitter.com/", "", "")),
            ]

            item, _ = keymap.popListWindow([("App", cblister_FixedPhrase(apps))])
            if item:
                item[1]()

        # Because the blocking procedure cannot be executed in the key-hook,
        keymap.delayedCall(pop_application_list, 0)

    keymap_global["U0-Shift-Space"] = command_pop_application_list


def jis_to_us_keyboard(keymap_global: KeymapPair):
    """
    Replacement key to use US keyboard with Japanese IME status.
    - See:
        - https://kts.sakaiweb.com/virtualkeycodes.html
        - https://github.com/dezz/ULE4JIS/blob/master/Ule4Jis/USonJISStrategy.cpp
    """

    # 半角/全角
    VK_OEM_AUTO = 243
    VK_OEM_ENLW = 244

    keymap_global["Shift-2"] = f"{VK_OEM_3}"  # to @
    keymap_global["Shift-6"] = f"{VK_OEM_7}"  # to ^
    keymap_global["Shift-7"] = "Shift-6"  # to &
    keymap_global["Shift-8"] = f"Shift-{VK_OEM_1}"  # to *
    keymap_global["Shift-9"] = "Shift-8"  # ) to (
    keymap_global["Shift-0"] = "Shift-9"  # to )
    keymap_global[f"Shift-{VK_OEM_MINUS}"] = f"Shift-{VK_OEM_102}"  # = to _
    keymap_global[f"{VK_OEM_7}"] = f"Shift-{VK_OEM_MINUS}"  # ^ to =
    keymap_global[f"Shift-{VK_OEM_7}"] = f"Shift-{VK_OEM_PLUS}"  # ~ to +
    keymap_global[f"{VK_OEM_AUTO}"] = f"Shift-{VK_OEM_3}"  # 半角/全角 to `
    keymap_global[f"{VK_OEM_ENLW}"] = f"Shift-{VK_OEM_3}"  # 半角/全角 to `
    keymap_global[f"Shift-{VK_OEM_AUTO}"] = f"Shift-{VK_OEM_7}"  # 半角/全角 to ~
    keymap_global[f"Shift-{VK_OEM_ENLW}"] = f"Shift-{VK_OEM_7}"  # shift-半角 to ~
    keymap_global[f"{VK_OEM_3}"] = f"{VK_OEM_4}"  # @ to [
    keymap_global[f"{VK_OEM_4}"] = f"{VK_OEM_6}"  # to ]
    keymap_global[f"Shift-{VK_OEM_3}"] = f"Shift-{VK_OEM_4}"  # to {
    keymap_global[f"Shift-{VK_OEM_4}"] = f"Shift-{VK_OEM_6}"  # to }
    keymap_global[f"Shift-{VK_OEM_PLUS}"] = f"{VK_OEM_1}"  # + to :
    keymap_global[f"{VK_OEM_1}"] = "Shift-7"  # : to '
    keymap_global[f"Shift-{VK_OEM_1}"] = "Shift-2"  # shift-: to "
    keymap_global[f"{VK_OEM_6}"] = f"{VK_OEM_102}"  # ] to \
    keymap_global[f"Shift-{VK_OEM_6}"] = f"Shift-{VK_OEM_5}"  # shift-] to |


def vim_keybinding(keymap_global: KeymapPair):
    keymap_global["LShift-Alt-H"] = "Left"
    keymap_global["LShift-Alt-J"] = "Down"
    keymap_global["LShift-Alt-K"] = "Up"
    keymap_global["LShift-Alt-L"] = "Right"
    keymap_global["LCtrl-H"] = "Back"
    keymap_global["LCtrl-M"] = "Enter"
    keymap_global[f"LCtrl-{VK_OEM_3}"] = "Escape"  # Ctrl-{ to Esc


def window_moving(keymap_global: KeymapPair, keymap: Keymap):
    """USER0-Ctrl-Up/Down/Left/Right : Move active window to screen edges"""
    keymap_global["U0-C-A"] = keymap.MoveWindowToMonitorEdgeCommand(0)
    keymap_global["U0-C-D"] = keymap.MoveWindowToMonitorEdgeCommand(2)
    keymap_global["U0-C-W"] = keymap.MoveWindowToMonitorEdgeCommand(1)
    keymap_global["U0-C-S"] = keymap.MoveWindowToMonitorEdgeCommand(3)


def macro_key(keymap_global: KeymapPair, keymap: Keymap):
    keymap_global["U0-0"] = keymap.command_RecordToggle
    keymap_global["U0-1"] = keymap.command_RecordStart
    keymap_global["U0-2"] = keymap.command_RecordStop
    keymap_global["U0-3"] = keymap.command_RecordPlay
    keymap_global["U0-4"] = keymap.command_RecordClear


def virtual_mouse(keymap_global: KeymapPair, keymap: Keymap):
    """USER0-Alt-↑/↓/←/→/Space/PageUp/PageDown : Virtual mouse by keyboard."""
    keymap_global["U0-Left"] = keymap.MouseMoveCommand(-10, 0)
    keymap_global["U0-Right"] = keymap.MouseMoveCommand(10, 0)
    keymap_global["U0-Up"] = keymap.MouseMoveCommand(0, -10)
    keymap_global["U0-Down"] = keymap.MouseMoveCommand(0, 10)
    keymap_global["D-U0-Space"] = keymap.MouseButtonDownCommand("left")
    keymap_global["U-U0-Space"] = keymap.MouseButtonUpCommand("left")


def cmd_keymap(keymap_global: KeymapPair, keymap: Keymap):
    def close():
        keymap.InputKeyCommand("Alt-F4")()

    def shutdown():
        os.system("shutdown -s")

    def sleep():  # https://qiita.com/sharow/items/ef78f2f5a8053f6a7a41
        shellExecute(
            None,
            "powershell.exe",
            "-NoProfile -Command \"Add-Type -Assembly System.Windows.Forms;\
[System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false);\"",
            "",
        )

    def win_terminal():
        shellExecute(None, "wt.exe", "", None)

    def win_terminal_as_admin():
        shellExecute(None, "sudo", "wt.exe", None)

    def clear_trash():
        shellExecute(
            None,
            "cmd.exe",
            "/c echo Y| powershell.exe -NoProfile -Command Clear-RecycleBin",
            None,
        )

    def open_task_manager():
        keymap.InputKeyCommand("LCtrl-LShift-Escape")()

    keymap_global["U0-C"] = close
    keymap_global["U0-Pause"] = shutdown
    keymap_global["U0-Period"] = open_task_manager
    keymap_global["U0-ScrollLock"] = sleep
    keymap_global["U0-Slash"] = clear_trash
    keymap_global["U0-T"] = win_terminal
    keymap_global["U0-Shift-T"] = win_terminal_as_admin


def input_keymap(keymap_global: KeymapPair, keymap: Keymap):
    keymap_global["U0-S"] = keymap.InputTextCommand("scoop search ")
    keymap_global["U0-A"] = keymap.InputTextCommand("update-all-libs")
    keymap_global["U0-D"] = keymap.InputTextCommand("…（´・ω・｀）")
    keymap_global["U0-F"] = keymap.InputTextCommand(" --help")
    keymap_global["U0-W"] = keymap.InputTextCommand("ほう…（´・ω・｀）?")


def turn_off_clipboard(keymap: Keymap):
    keymap.clipboard_history.enableHook(False)  # clipboard monitoring hook
    keymap.clipboard_history.maxnum = 0
    keymap.clipboard_history.quota = 0
