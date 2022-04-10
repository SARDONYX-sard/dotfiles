"""
.EXAMPLE
  # Install with manager.
  util-packages.py --manager pacman
  util-packages.py --manager apt

  # Uninstall global packages.
  util-packages.py --manager pacman --uninstall
  util-packages.py --manager apt --Uninstall
"""


import argparse
from os import system
from shutil import which
import sys
from typing import Literal


common_libs = [
    # Utils
    {"name": "curl git zip unzip", "description": "utils"},
    {"name": "exuberant-ctags", "description": "For editor."},

    {"name": "gawk", "description": "For fzf dependency."},
    {"name": "fzf", "description": "fuzzy finder."},

    # Shell
    {"name": "fish", "description": "fish shell."},

    # Monitor
    {"name": "sysstat", "description": "Process Monitor."},

    # ------------ Coding -----------
    {"name": "source-highlight", "description": "Syntax highlighting for less command."},

    # Editor
    {"name": "neovim", "description": "Editor."},
    {"name": "rlwrap",
     "description": "History function can be added to commands that do not have history function.\
    (http://x68000.q-e-d.net/~68user/unix/pickup?rlwrap)"},
    {"name": "tmux",
     "description": "tmux is a terminal multiplexer. It allows you to execute multiple programs in one terminal window."}
]

desk_libs = [
    # ! autokey-gtk isn't available in pacman.
    {"name": "autokey-gtk", "description": "keyboard hook."},
]

apt_only_libs = [
    {"name": "bat & ripgrep", "description": "bat==cat / grep written in rust.",
     "installer": "sudo apt install -o Dpkg::Options::=\" - -force - overwrite\" bat ripgrep -y)"
     },
    {"name": "fd-find", "description": "better find command"},
]


pacman_only_libs = [
    {"name": "bat", "description": "better cat written in rust."},
    {"name": "fd", "description": "better find command"},
    {"name": "inetutils", "description": "Network utils.(for hostname command)"},
    {"name": "ripgrep", "description": "better grep."}
]


def color(string: str, mode: Literal["green", "red", "yellow", "cyan"]):
    colors = {
        "red": "\033[31m",
        "green": "\033[32m",
        "yellow": "\033[33m",
        "cyan": "\033[36m"}
    return f'{colors[mode]}{string}\033[0m'


# --------------------------------------------------------------------------------------------------
# Installer functions
# --------------------------------------------------------------------------------------------------
def check_python_available():
    if which("python"):
        return True
    print("Python is not available.")
    color(
        "WARNING: Python is not installed.\n Please install Python before running this.",
        'yellow')
    sys.exit(-1)


def get_args():
    # prepare
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-m",
        "--manager",
        type=str,
        help="Select the manager to use. (apt | pacman) default: apt",
        default="apt")
    parser.add_argument(
        "-p",
        "--plus",
        help="Use Desktop libs",
        action="store_false")
    parser.add_argument(
        "-uni",
        "--uninstall",
        help="Change uninstall mode.",
        action="store_false")

    return (parser.parse_args())


def initialize(manager: Literal["apt", "pacman", "yay"]):
    """Update packages database """

    if manager == "apt":
        system("sudo apt update - y; apt upgrade - y; sudo apt autoremove -y")
    elif manager == "pacman":
        system("sudo pacman -Syu")
    elif manager == "yay":
        system("yay -Syu")


def manage_libs(manager: Literal["apt", "pacman", "yay"],
                mode: Literal["install", "uninstall"], is_desk: bool):
    if manager == "apt":
        prefix = "sudo apt install -y" if mode == "install" else "sudo apt remove -y"
        manage_lib(prefix, apt_only_libs)

    elif manager in ["pacman", "yay"]:
        prefix = "sudo pacman -S --noconfirm" if mode == "install" else "sudo pacman -Rns --noconfirm"
        if manager == "yay":
            prefix = "yay -S --noconfirm" if mode == "install" else "yay -Rns --noconfirm"
        manage_lib(prefix, pacman_only_libs)

    else:
        print(color("ERROR: Invalid manager.", 'red'))
        sys.exit(-1)

    manage_lib(prefix, common_libs)
    if is_desk and manager in ["yay", "apt"]:
        manage_lib(prefix, desk_libs)


def manage_lib(prefix: str, libraries: list[dict[str, str]]):
    for lib in libraries:
        [name, description] = [lib["name"], lib["description"]]

        print(color(f"INFO:{name}/{description}", 'blue'))

        if lib["installer"]:
            system(lib["installer"])
            continue

        system(f"{prefix} {name}")
        print("")


def main():
    initialize(manager)

    if uninstall:
        manage_libs(manager, "uninstall", plus)
    else:
        manage_libs(manager, "install", plus)

    print(color("Successes: Finished working on all libraries.", 'green'))


if __name__ == '__main__':
    args = get_args()
    manager, plus, uninstall = [args.manager, args.plus, args.uninstall]
    print(f"{manager} has been selected.")
    main()
