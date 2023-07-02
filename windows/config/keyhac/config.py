"""KeyHac config

https://sites.google.com/site/craftware/
"""

import datetime
import os

# pyauto  ref: (https://github.com/crftwr/pyauto/blob/master/doc/pyauto.py)
# import pyauto
from keyhac import shellExecute, getDesktopPath, getClipboardText, cblister_FixedPhrase
from keyhac import Keymap


def configure(keymap: Keymap):
    keymap_global = keymap.defineWindowKeymap()

    keymap.defineModifier(235, "User0")  # User modifier key definition
    keymap.replaceKey("RShift", 235)  # Simple key replacement

    keymap.editor = "nvim.exe" if os.name == "nt" else "nvim"
    keymap.setFont("MS Gothic", 12)
    keymap.setTheme("black")

    # Global keymap which affects any windows
    if 1:
        # vim like
        keymap_global["LShift-Alt-H"] = "Left"
        keymap_global["LShift-Alt-J"] = "Down"
        keymap_global["LShift-Alt-K"] = "Up"
        keymap_global["LShift-Alt-L"] = "Right"

        keymap_global["LCtrl-H"] = "Back"
        keymap_global["LCtrl-M"] = "Enter"
        keymap_global["LCtrl-OpenBracket"] = "Escape"

        # USER0-Ctrl-Up/Down/Left/Right : Move active window to screen edges
        keymap_global["U0-C-A"] = keymap.MoveWindowToMonitorEdgeCommand(0)
        keymap_global["U0-C-D"] = keymap.MoveWindowToMonitorEdgeCommand(2)
        keymap_global["U0-C-W"] = keymap.MoveWindowToMonitorEdgeCommand(1)
        keymap_global["U0-C-S"] = keymap.MoveWindowToMonitorEdgeCommand(3)

        keymap.quote_mark = "> "

        # Keyboard macro
        keymap_global["U0-0"] = keymap.command_RecordToggle
        keymap_global["U0-1"] = keymap.command_RecordStart
        keymap_global["U0-2"] = keymap.command_RecordStop
        keymap_global["U0-3"] = keymap.command_RecordPlay
        keymap_global["U0-4"] = keymap.command_RecordClear

    # USER0-Space : Application launcher using custom list window
    if 1:

        def command_pop_application_list():
            # For toggle window.
            if keymap.isListWindowOpened():
                keymap.cancelListWindow()
                return

            def pop_application_list():
                # config
                dl_dir = "E:\\ダウンロード"

                shell = keymap.ShellExecuteCommand
                is_win = os.name == "nt"
                shell_neovide = shell(None, "neovide.exe", "", "") if is_win else None
                apps = [
                    ("-- Editor --", shell_neovide),
                    ("Neovide", shell_neovide),
                    ("Notepad", shell(None, "notepad.exe", "", "") if is_win else None),
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
            # delayed-execute the procedure by delayedCall().
            keymap.delayedCall(pop_application_list, 0)

        keymap_global["U0-Shift-Space"] = command_pop_application_list

    if 1:
        # USER0-Alt-↑/↓/←/→/Space/PageUp/PageDown : Virtual mouse by keyboard.
        keymap_global["U0-Left"] = keymap.MouseMoveCommand(-10, 0)
        keymap_global["U0-Right"] = keymap.MouseMoveCommand(10, 0)
        keymap_global["U0-Up"] = keymap.MouseMoveCommand(0, -10)
        keymap_global["U0-Down"] = keymap.MouseMoveCommand(0, 10)
        keymap_global["D-U0-Space"] = keymap.MouseButtonDownCommand("left")
        keymap_global["U-U0-Space"] = keymap.MouseButtonUpCommand("left")

    # Execute the System commands by sendMessage
    if 1:

        def close():
            keymap.InputKeyCommand("Alt-F4")()

        def shutdown():
            os.system("shutdown -s")

        def sleep():  # https://qiita.com/sharow/items/ef78f2f5a8053f6a7a41
            shellExecute(
                None,
                "powershell.exe",
                "-NoProfile -Command \
\"Add-Type -Assembly \
System.Windows.Forms;\
[System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false);\
\"",
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

        keymap_global["U0-LShift-T"] = win_terminal_as_admin

    if 1:
        keymap_global["U0-S"] = keymap.InputTextCommand("scoop search ")

        keymap_global["U0-A"] = keymap.InputTextCommand("update-all-libs")
        keymap_global["U0-D"] = keymap.InputTextCommand("…（´・ω・｀）")
        keymap_global["U0-F"] = keymap.InputTextCommand(" --help")
        keymap_global["U0-W"] = keymap.InputTextCommand("ほう…（´・ω・｀）？")

    if 1:  # Customizing clipboard history list
        keymap.clipboard_history.enableHook(False)  # clipboard monitoring hook
        keymap.clipboard_history.maxnum = 0
        keymap.clipboard_history.quota = 10 * 1024 * 1024

        # Fixed phrases
        fixed_items = [
            ("name@server.net", "name@server.net"),
            ("Address", "San Francisco, CA 94128"),
            ("Phone number", "03-4567-8901"),
        ]

        # Return formatted date-time string
        def date_and_time(fmt: str):
            return lambda: datetime.datetime.now().strftime(fmt)

        # Date-time
        datetime_items = [
            ("YYYY/MM/DD HH:MM:SS", date_and_time("%Y/%m/%d %H:%M:%S")),
            ("YYYY/MM/DD", date_and_time("%Y/%m/%d")),
            ("HH:MM:SS", date_and_time("%H:%M:%S")),
            ("YYYYMMDD_HHMMSS", date_and_time("%Y%m%d_%H%M%S")),
            ("YYYYMMDD", date_and_time("%Y%m%d")),
            ("HHMMSS", date_and_time("%H%M%S")),
        ]

        # Add quote mark to current clipboard contents
        def quote_clipboard_text():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = "".join(keymap.quote_mark + line for line in lines)
            return s

        # Indent current clipboard contents
        def indent_clipboard_text():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = ""
            for line in lines:
                if line.lstrip():
                    line = " " * 4 + line
                s += line
            return s

        # Unindent current clipboard contents
        def unindent_clipboard_text():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = ""
            for line in lines:
                for i in range(4 + 1):
                    if i >= len(line):
                        break
                    if line[i] == "\t":
                        i += 1
                        break
                    if line[i] != " ":
                        break
                    s += line[i:]
            return s

        full_width_chars = "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ\
ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ\
！”＃＄％＆’（）＊＋，−．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～０１２３４５６７８９　"
        half_width_chars = "abcdefghijklmnopqrstuvwxyz\
ABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}～0123456789 "

        # Convert to half-with characters
        def to_half_width_clipboard_text():
            s = getClipboardText()
            s = s.translate(str.maketrans(full_width_chars, half_width_chars))
            return s

        # Convert to full-with characters
        def to_full_width_clipboard_text():
            s = getClipboardText()
            s = s.translate(str.maketrans(half_width_chars, full_width_chars))
            return s

        # Save the clipboard contents as a file in Desktop directory
        def command_save_clipboard_to_desktop():
            text = getClipboardText()
            if not text:
                return

            # Convert to utf-8 / CR-LF
            utf8_bom = b"\xEF\xBB\xBF"
            text = text.replace("\r\n", "\n")
            text = text.replace("\r", "\n")
            text = text.replace("\n", "\r\n")
            text = text.encode(encoding="utf-8")

            # Save in Desktop directory
            fullpath = os.path.join(
                getDesktopPath(),
                datetime.datetime.now().strftime("clip_%Y%m%d_%H%M%S.txt"),
            )
            with open(fullpath, "wb") as fd:
                fd.write(utf8_bom)
                fd.write(text)
            # Open by the text editor
            keymap.editTextFile(fullpath)

        # Menu item list
        separetor = ("", None)
        other_items = [
            ("Quote clipboard", quote_clipboard_text),
            ("Indent clipboard", indent_clipboard_text),
            ("Unindent clipboard", unindent_clipboard_text),
            separetor,
            ("To Half-Width", to_half_width_clipboard_text),
            ("To Full-Width", to_full_width_clipboard_text),
            separetor,
            ("Save clipboard to Desktop", command_save_clipboard_to_desktop),
            separetor,
            ("Edit config.py", keymap.command_EditConfig),
            ("Reload config.py", keymap.command_ReloadConfig),
        ]

        # Clipboard history list extensions
        keymap.cblisters += [
            ("Fixed phrase", cblister_FixedPhrase(fixed_items)),
            ("Date-time", cblister_FixedPhrase(datetime_items)),
            ("Others", cblister_FixedPhrase(other_items)),
        ]
