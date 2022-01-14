"""KeyHac config

https://sites.google.com/site/craftware/
"""

from ctypes import CFUNCTYPE, WinDLL, c_uint32, cast
import datetime
import os
import sys

import pyauto
from keyhac import *


def configure(keymap):

    # --------------------------------------------------------------------
    # Text editor setting for editting config.py file

    # Setting with program file path (Simple usage)
    if 1:
        keymap.editor = "notepad++.exe"

    # --------------------------------------------------------------------
    # Customizing the display

    # Font
    keymap.setFont("MS Gothic", 12)

    # Theme
    keymap.setTheme("black")

    # --------------------------------------------------------------------

    # Simple key replacement
    keymap.replaceKey("RShift", 235)

    # User modifier key definition
    keymap.defineModifier(235, "User0")

    # Global keymap which affects any windows
    if 1:
        keymap_global = keymap.defineWindowKeymap()

        # vim like
        keymap_global["LShift-Alt-H"] = "Left"
        keymap_global["LShift-Alt-J"] = "Down"
        keymap_global["LShift-Alt-K"] = "Up"
        keymap_global["LShift-Alt-L"] = "Right"

        keymap_global["LCtrl-H"] = "Back"
        keymap_global["LCtrl-M"] = "Enter"
        keymap_global["LCtrl-I"] = "Tab"
        keymap_global["LCtrl-OpenBracket"] = "Escape"

        # USER0-Ctrl-Up/Down/Left/Right : Move active window to screen edges
        keymap_global["U0-C-A"] = keymap.MoveWindowToMonitorEdgeCommand(0)
        keymap_global["U0-C-D"] = keymap.MoveWindowToMonitorEdgeCommand(2)
        keymap_global["U0-C-W"] = keymap.MoveWindowToMonitorEdgeCommand(1)
        keymap_global["U0-C-S"] = keymap.MoveWindowToMonitorEdgeCommand(3)

        # Clipboard history related
        # Open the clipboard history list
        keymap_global["U0-C-S-Z"] = keymap.command_ClipboardList
        # Move the most recent history to tail
        keymap_global["U0-C-S-X"] = keymap.command_ClipboardRotate
        # Remove the most recent history
        keymap_global["U0-C-S-A-X"] = keymap.command_ClipboardRemove
        # Mark for quote pasting
        keymap.quote_mark = "> "

        # Keyboard macro
        keymap_global["U0-0"] = keymap.command_RecordToggle
        keymap_global["U0-1"] = keymap.command_RecordStart
        keymap_global["U0-2"] = keymap.command_RecordStop
        keymap_global["U0-3"] = keymap.command_RecordPlay
        keymap_global["U0-4"] = keymap.command_RecordClear

    # us to js
    # (https://ossyaritoori.hatenablog.com/entry/2020/09/16/Autohotkeyを用いてWindowsでUS配列キーボードをJIS配列設定で使)
    if 0:
        keymap.replaceKey("DoubleQuote", "Atmark")
        keymap.replaceKey("And", "Caret")
        keymap.replaceKey("singleQuote", "And")
        keymap.replaceKey("Asterisk", "DoubleQuote")

    # USER0-F2 : Test of sub thread execution using JobQueue/JobItem
    if 1:
        def command_JobTest():

            def open_memo(job_item):
                shellExecute(
                    None,
                    "notepad++.exe",
                    "",
                    "C:/Users/SARDONYX/OneDrive/文書")

            def jobTestFinished(job_item):
                print("Done.")

            job_item = JobItem(open_memo, jobTestFinished)
            JobQueue.defaultQueue().enqueue(job_item)

        keymap_global["U0-F2"] = command_JobTest

    # Test of Cron (periodic sub thread procedure)
    if 0:
        def cronPing(cron_item):
            os.system("ping -n 3 www.google.com")

        cron_item = CronItem(cronPing, 3.0)
        CronTable.defaultCronTable().add(cron_item)

    # USER0-Space : Application launcher using custom list window
    if 1:
        def command_PopApplicationList():

            # If the list window is already opened, just close it
            if keymap.isListWindowOpened():
                keymap.cancelListWindow()
                return

            def popApplicationList():

                applications = [
                    ("Notepad", keymap.ShellExecuteCommand(
                        None, "notepad.exe", "", "")), ("Paint", keymap.ShellExecuteCommand(
                            None, "mspaint.exe", "", "")), ]

                websites = [
                    ("Google",
                     keymap.ShellExecuteCommand(
                         None,
                         "https://www.google.co.jp/",
                         "",
                         "")),
                    ("Facebook",
                     keymap.ShellExecuteCommand(
                         None,
                         "https://www.facebook.com/",
                         "",
                         "")),
                    ("Twitter",
                     keymap.ShellExecuteCommand(
                         None,
                         "https://twitter.com/",
                         "",
                         "")),
                ]

                listers = [
                    ("App", cblister_FixedPhrase(applications)),
                    ("WebSite", cblister_FixedPhrase(websites)),
                ]

                item, mod = keymap.popListWindow(listers)

                if item:
                    item[1]()

            # Because the blocking procedure cannot be executed in the key-hook,
            # delayed-execute the procedure by delayedCall().
            keymap.delayedCall(popApplicationList, 0)

        keymap_global["U0-Space"] = command_PopApplicationList

    # USER0-Alt-Up/Down/Left/Right/Space/PageUp/PageDown : Virtul mouse
    # operation by keyboard
    if 1:
        # keymap_global["U0-A"] = keymap.MouseMoveCommand(-10, 0)
        # keymap_global["U0-D"] = keymap.MouseMoveCommand(10, 0)
        # keymap_global["U0-W"] = keymap.MouseMoveCommand(0, -10)
        # keymap_global["U0-S"] = keymap.MouseMoveCommand(0, 10)
        keymap_global["U0-Left"] = keymap.MouseMoveCommand(-10, 0)
        keymap_global["U0-Right"] = keymap.MouseMoveCommand(10, 0)
        keymap_global["U0-Up"] = keymap.MouseMoveCommand(0, -10)
        keymap_global["U0-Down"] = keymap.MouseMoveCommand(0, 10)
        keymap_global["D-U0-Space"] = keymap.MouseButtonDownCommand('left')
        keymap_global["U-U0-Space"] = keymap.MouseButtonUpCommand('left')

    # Execute the System commands by sendMessage
    if 1:
        def close():
            wnd = keymap.getTopLevelWindow()
            wnd.sendMessage(WM_SYSCOMMAND, SC_CLOSE)

        def shutdown():
            os.system('shutdown -s')

        def sleep():  # https://qiita.com/sharow/items/ef78f2f5a8053f6a7a41
            user32 = WinDLL('User32')
            DISPLAY_OFF = 2
            HWND_BROADCAST = 0xffff
            WM_SYSCOMMAND = 0x0112
            SC_MONITORPOWER = 0xf170
            post_message = cast(
                user32.PostMessageA,
                CFUNCTYPE(
                    c_uint32,
                    c_uint32,
                    c_uint32,
                    c_uint32,
                    c_uint32))

            post_message(HWND_BROADCAST,
                         WM_SYSCOMMAND,
                         SC_MONITORPOWER,
                         DISPLAY_OFF)

        # keymap_global["U0-C"] = close              # Close the window
        keymap_global["U0-ScrollLock"] = sleep
        keymap_global["U0-Pause"] = shutdown

    # Test of text input
    if 1:
        def input_func(text: str):
            def _input_func():
                keymap.InputKeyCommand("Escape")()
                keymap.InputTextCommand(text)()
            return _input_func

        keymap_global["U0-F"] = keymap.InputTextCommand(" --help")
        keymap_global["U0-A"] = input_func("Update-AllLibs")
        keymap_global["U0-S"] = input_func("scoop search ")
        keymap_global["U0-W"] = input_func("なるほどね。(*´ω`*)")

    # Customizing clipboard history list
    if 1:
        # Enable clipboard monitoring hook (Default:Enabled)
        keymap.clipboard_history.enableHook(True)

        # Maximum number of clipboard history (Default:1000)
        keymap.clipboard_history.maxnum = 1000

        # Total maximum size of clipboard history (Default:10MB)
        keymap.clipboard_history.quota = 10 * 1024 * 1024

        # Fixed phrases
        fixed_items = [
            ("name@server.net", "name@server.net"),
            ("Address", "San Francisco, CA 94128"),
            ("Phone number", "03-4567-8901"),
        ]

        # Return formatted date-time string
        def dateAndTime(fmt):
            def _dateAndTime():
                return datetime.datetime.now().strftime(fmt)
            return _dateAndTime

        # Date-time
        datetime_items = [
            ("YYYY/MM/DD HH:MM:SS", dateAndTime("%Y/%m/%d %H:%M:%S")),
            ("YYYY/MM/DD", dateAndTime("%Y/%m/%d")),
            ("HH:MM:SS", dateAndTime("%H:%M:%S")),
            ("YYYYMMDD_HHMMSS", dateAndTime("%Y%m%d_%H%M%S")),
            ("YYYYMMDD", dateAndTime("%Y%m%d")),
            ("HHMMSS", dateAndTime("%H%M%S")),
        ]

        # Add quote mark to current clipboard contents
        def quoteClipboardText():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = "".join(keymap.quote_mark + line for line in lines)
            return s

        # Indent current clipboard contents
        def indentClipboardText():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = ""
            for line in lines:
                if line.lstrip():
                    line = " " * 4 + line
                s += line
            return s

        # Unindent current clipboard contents
        def unindentClipboardText():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = ""
            for line in lines:
                for i in range(4 + 1):
                    if i >= len(line):
                        break
                    if line[i] == '\t':
                        i += 1
                        break
                    if line[i] != ' ':
                        break
                s += line[i:]
            return s

        full_width_chars = "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ！”＃＄％＆’（）＊＋，−．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～０１２３４５６７８９　"
        half_width_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}～0123456789 "

        # Convert to half-with characters
        def toHalfWidthClipboardText():
            s = getClipboardText()
            s = s.translate(str.maketrans(full_width_chars, half_width_chars))
            return s

        # Convert to full-with characters
        def toFullWidthClipboardText():
            s = getClipboardText()
            s = s.translate(str.maketrans(half_width_chars, full_width_chars))
            return s

        # Save the clipboard contents as a file in Desktop directory
        def command_SaveClipboardToDesktop():

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
                datetime.datetime.now().strftime("clip_%Y%m%d_%H%M%S.txt"))
            with open(fullpath, "wb") as fd:
                fd.write(utf8_bom)
                fd.write(text)
            # Open by the text editor
            keymap.editTextFile(fullpath)

        # Menu item list
        other_items = [
            ("Quote clipboard", quoteClipboardText),
            ("Indent clipboard", indentClipboardText),
            ("Unindent clipboard", unindentClipboardText),
            ("", None),
            ("To Half-Width", toHalfWidthClipboardText),
            ("To Full-Width", toFullWidthClipboardText),
            ("", None),
            ("Save clipboard to Desktop", command_SaveClipboardToDesktop),
            ("", None),
            ("Edit config.py", keymap.command_EditConfig),
            ("Reload config.py", keymap.command_ReloadConfig),
        ]

        # Clipboard history list extensions
        keymap.cblisters += [
            ("Fixed phrase", cblister_FixedPhrase(fixed_items)),
            ("Date-time", cblister_FixedPhrase(datetime_items)),
            ("Others", cblister_FixedPhrase(other_items)),
        ]