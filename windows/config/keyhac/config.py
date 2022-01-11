"""KeyHac config

https://sites.google.com/site/craftware/
"""

import sys
import os
import datetime

import pyauto
from keyhac import *


def configure(keymap):

    # --------------------------------------------------------------------
    # Text editer setting for editting config.py file

    # Setting with program file path (Simple usage)
    if 1:
        keymap.editor = "notepad++.exe"

    # Setting with callable object (Advanced usage)
    if 0:
        def editor(path):
            shellExecute(None, "notepad.exe", '"%s"' % path, "")
        keymap.editor = editor

    # --------------------------------------------------------------------
    # Customizing the display

    # Font
    keymap.setFont("MS Gothic", 12)

    # Theme
    keymap.setTheme("black")

    # --------------------------------------------------------------------

    # Simple key replacement
    keymap.replaceKey("LWin", 235)

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

        # USER0-Up/Down/Left/Right : Move active window by 10 pixel unit
        keymap_global["U0-Left"] = keymap.MoveWindowCommand(-10, 0)
        keymap_global["U0-Right"] = keymap.MoveWindowCommand(+10, 0)
        keymap_global["U0-Up"] = keymap.MoveWindowCommand(0, -10)
        keymap_global["U0-Down"] = keymap.MoveWindowCommand(0, +10)

        # USER0-Ctrl-Up/Down/Left/Right : Move active window to screen edges
        keymap_global["U0-C-Left"] = keymap.MoveWindowToMonitorEdgeCommand(0)
        keymap_global["U0-C-Right"] = keymap.MoveWindowToMonitorEdgeCommand(2)
        keymap_global["U0-C-Up"] = keymap.MoveWindowToMonitorEdgeCommand(1)
        keymap_global["U0-C-Down"] = keymap.MoveWindowToMonitorEdgeCommand(3)

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

    # USER0-F1 : Test of launching application
    if 1:
        keymap_global["U0-F1"] = keymap.ShellExecuteCommand(
            None, "notepad++.exe", "", "")

    # USER0-F2 : Test of sub thread execution using JobQueue/JobItem
    if 1:
        def command_JobTest():

            def jobTest(job_item):
                shellExecute(None, "notepad.exe", "", "")

            def jobTestFinished(job_item):
                print("Done.")

            job_item = JobItem(jobTest, jobTestFinished)
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
        keymap_global["U0-A-Left"] = keymap.MouseMoveCommand(-10, 0)
        keymap_global["U0-A-Right"] = keymap.MouseMoveCommand(10, 0)
        keymap_global["U0-A-Up"] = keymap.MouseMoveCommand(0, -10)
        keymap_global["U0-A-Down"] = keymap.MouseMoveCommand(0, 10)
        keymap_global["D-U0-A-Space"] = keymap.MouseButtonDownCommand('left')
        keymap_global["U-U0-A-Space"] = keymap.MouseButtonUpCommand('left')
        keymap_global["U0-A-PageUp"] = keymap.MouseWheelCommand(1.0)
        keymap_global["U0-A-PageDown"] = keymap.MouseWheelCommand(-1.0)
        keymap_global["U0-A-Home"] = keymap.MouseHorizontalWheelCommand(-1.0)
        keymap_global["U0-A-End"] = keymap.MouseHorizontalWheelCommand(1.0)

    # Execute the System commands by sendMessage
    if 1:
        def close():
            wnd = keymap.getTopLevelWindow()
            wnd.sendMessage(WM_SYSCOMMAND, SC_CLOSE)

        def screenSaver():
            wnd = keymap.getTopLevelWindow()
            wnd.sendMessage(WM_SYSCOMMAND, SC_SCREENSAVE)

        def slepp():
            wnd = keymap.getTopLevelWindow()
            wnd.sendMessage(WM_SYSCOMMAND, SC_CLOSE)

        keymap_global["U0-C"] = close              # Close the window

    # Test of text input
    if 1:
        keymap_global["U0-H"] = keymap.InputTextCommand("Hello / こんにちは")

    # Customize Notepad as Emacs-ish
    # Because the keymap condition of keymap_edit overlaps with keymap_notepad,
    # both these two keymaps are applied in mixed manner.
    if 0:
        keymap_notepad = keymap.defineWindowKeymap(
            exe_name="notepad.exe", class_name="Edit")

        # Define Ctrl-X as the first key of multi-stroke keys
        keymap_notepad["C-X"] = keymap.defineMultiStrokeKeymap("C-X")

        keymap_notepad["C-P"] = "Up"                  # Move cursor up
        keymap_notepad["C-N"] = "Down"                # Move cursor down
        keymap_notepad["C-F"] = "Right"               # Move cursor right
        keymap_notepad["C-B"] = "Left"                # Move cursor left

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
            s = ""
            for line in lines:
                s += keymap.quote_mark + line
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
            fd = open(fullpath, "wb")
            fd.write(utf8_bom)
            fd.write(text)
            fd.close()

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
