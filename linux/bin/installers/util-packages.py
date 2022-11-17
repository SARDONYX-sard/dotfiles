"""
.EXAMPLE
  # Install with manager.
  python3 util-packages.py --manager yay
  python3 util-packages.py --manager pacman
  python3 util-packages.py --manager apt

  # Uninstall global packages.
  python3 util-packages.py --manager yay --uninstall
  python3 util-packages.py --manager pacman --uninstall
  python3 util-packages.py --manager apt --Uninstall


  # global packages additional install.
  python3 util-packages.py --manager yay --plus
  python3 util-packages.py --manager pacman --plus
  python3 util-packages.py --manager apt --plus
"""


import argparse
from os import system
from shutil import which
import sys
from typing import Literal


common_libs = [
    # Utils
    {"name": "curl git make sudo unzip wget which zip", "description": "utils"},
    {"name": "exuberant-ctags", "description": "For editor."},
    {"name": "openssh", "description": "For ssh-keygen command"},
    {"name": "zoxide", "description": "A smarter cd command."},
    {"name": "gawk", "description": "For fzf dependency."},
    {"name": "fzf", "description": "fuzzy finder."},
    # Shell
    {"name": "fish", "description": "fish shell."},
    {"name": "zsh", "description": "zsh shell"},
    # Monitor
    {"name": "sysstat", "description": "Process Monitor."},
    # ------------ Coding -----------
    {"name": "shellcheck", "description": "Shell script checker."},
    {
        "name": "source-highlight",
        "description": "Syntax highlighting for less command.",
    },
    # Editor
    {"name": "neovim", "description": "Editor."},
    {"name": "luarocks", "description": "lua package manager.(to use luacheck)"},
    {
        "name": "rlwrap",
        "description": "History function can be added to commands that do not have history function.\
    (http://x68000.q-e-d.net/~68user/unix/pickup?rlwrap)",
    },
    {
        "name": "tmux",
        "description": "tmux is a terminal multiplexer. It allows you to execute multiple programs in one terminal window.",
    },
]

desk_libs = [
    # ! autokey-gtk isn't available in pacman.
    {"name": "autokey-gtk", "description": "keyboard hook."},
]

apt_only_libs = [
    {
        "name": "bat & ripgrep",
        "description": "bat==cat / grep written in rust.",
        "installer": 'sudo apt install -o Dpkg::Options::=" - -force - overwrite" bat ripgrep -y)',
    },
    {"name": "exa", "description": "color ls command"},
    {"name": "fd-find", "description": "better find command"},
]


pacman_only_libs = [
    {"name": "bat", "description": "better cat written in rust."},
    {"name": "fd", "description": "better find command"},
    {"name": "inetutils", "description": "Network utils.(for hostname command)"},
    {"name": "lsd", "description": "The next gen ls command."},
    {"name": "lazygit", "description": "A simple terminal UI for git commands."},
    {"name": "ripgrep", "description": "better grep."},
]


def color(string: str, mode: Literal["green", "red", "yellow", "cyan"]):
    colors = {
        "red": "\033[31m",
        "green": "\033[32m",
        "yellow": "\033[33m",
        "cyan": "\033[36m",
    }
    return f"{colors[mode]}{string}\033[0m"


# --------------------------------------------------------------------------------------------------
# Installer functions
# --------------------------------------------------------------------------------------------------
def check_python_available():
    if which("python"):
        return True
    print("Python is not available.")
    color(
        "WARNING: Python is not installed.\n Please install Python before running this.",
        "yellow",
    )
    sys.exit(-1)


def get_args():
    # prepare
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-m",
        "--manager",
        type=str,
        help="Select the manager to use. (apt | pacman) default: apt",
        default="apt",
    )
    parser.add_argument("-p", "--plus", type=bool, help="Use Desktop libs")
    parser.add_argument("-uni", "--uninstall", type=bool, help="Change uninstall mode.")

    return parser.parse_args()


def initialize(manager: Literal["apt", "pacman", "yay"]):
    print(color("Update packages database", "cyan"))

    if manager == "apt":
        system(
            " sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y"
        )
    elif manager == "pacman":
        system("sudo pacman -Syu --noconfirm")
    elif manager == "yay":
        system("yay -Syu --noconfirm")


def manage_libs(
    manager: Literal["apt", "pacman", "yay"],
    mode: Literal["install", "uninstall"],
    is_desk: bool,
):
    if manager == "apt":
        prefix = "sudo apt install -y" if mode == "install" else "sudo apt remove -y"
        manage_lib(prefix, apt_only_libs)

    elif manager in ["pacman", "yay"]:
        prefix = (
            "sudo pacman -S --noconfirm"
            if mode == "install"
            else "sudo pacman -Rns --noconfirm"
        )
        if manager == "yay":
            prefix = (
                "yay -S --noconfirm" if mode == "install" else "yay -Rns --noconfirm"
            )
        manage_lib(prefix, pacman_only_libs)

    else:
        print(color("ERROR: Invalid manager.", "red"))
        sys.exit(-1)

    manage_lib(prefix, common_libs)
    if is_desk and manager in ["yay", "apt"]:
        manage_lib(prefix, desk_libs)


def manage_lib(prefix: str, libraries: list[dict[str, str]]):
    for lib in libraries:
        [name, description] = [lib["name"], lib["description"]]
        name_title = color("Name", "green")
        description_title = color("Description", "cyan")

        print(
            "-----------------------------------------------------------------------------------"
        )
        print(f"{name_title}: {name}")
        print(f"{description_title}: {description}")

        if "installer" in lib:
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

    print(color("Successes: Finished working on all libraries.", "green"))


if __name__ == "__main__":
    args = get_args()
    manager, plus, uninstall = [args.manager, args.plus, args.uninstall]
    print(f"{manager} has been selected.")
    main()
