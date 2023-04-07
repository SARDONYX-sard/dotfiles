"""
.EXAMPLE
  # Install with manager.
  pip.py --manager pip
  pip.py --manager conda

  # Uninstall global packages.
  pip.py --manager pip --uninstall
  pip.py --manager conda --Uninstall

.NOTES
  # You can install with libraries list(windows\\data\requirements.txt)
  pip install -r requirements.txt


  # How to output requirements.txt
  pip freeze > requirements.txt
"""


import argparse
from os import system
from shutil import which
from typing import Literal


libs = [
    # Formatter & Linter
    {"name": "black", "description": "formatter."},
    {"name": "ruff", "description": "linter."},
    {"name": "codespell", "description": "spell checker."},
    # Manager(For update libs)
    {"name": "pip-search", "description": "Search PyPI."},
    {"name": "pip-review", "description": "update modules."},
    {
        "name": "pipx",
        "description": "(need pip >= 19)Install and Run Python Applications in Isolated Environments.",
    },
    {
        # ? Install with pipx to avoid conflict errors. Add poetry to path by `ensurepath` command.
        # There is one on scoop, but the deprecation statement appeared.
        "name": "poetry",
        "description": "python package manager.",
        "installer": "pipx install poetry",
    },
    # Other language
    {"name": "fprettify", "description": "fortran formatter."},
    # Editor
    # {"name": "neovim", "description": "vim."}
]

heavy_libs = [
    # Conveniences
    {"name": "cython", "description": "C."},
    # https://github.com/jupyter/noteboo,
    {"name": "notebook", "description": "jupyter notebook."},
    # {"name": "selenium", "description": "E2E testing library."},
]


def color(string: str, mode: Literal["green", "red", "yellow", "cyan"]):
    colors = {
        "red": "\033[31m",
        "green": "\033[32m",
        "yellow": "\033[33m",
        "cyan": "\033[36m",
    }
    return f"{colors[mode]}{string}\033[0m"


def check_python_available():
    if which("python"):
        return True
    print("Python is not available.")
    color("WARNING: Python is not installed.", "yellow")

    if which("pyenv"):
        print(color("Found pyenv.", "cyan"))
        print(color("Trying to install with pyenv...", "cyan"))
        system("pyenv install 3.8.10")

    import os

    if os.name == "nt" and bool(which("scoop")):
        print(color("Trying to install with scoop...", "cyan"))
        # latest python version (e.g. python3.10)
        system("scoop install python")

    elif os.name == "posix":
        if which("rtx"):
            system("rtx install python3@3.8.10")
        elif which("asdf"):
            system("asdf install python3@3.8.10")

    else:
        print(color("Python cannot installed.", "red"))
        print(
            "\
            You can install it in one of the following ways. \
\
            Manually install:\
            Go to https: // python.org\
\
\
            Install with Scoop:\
            Execute the following commands.↓ \
\
            Invoke - WebRequest - useb get.scoop.sh | Invoke - Expression\
            scoop install python \
            "
        )
    return False


def get_args():
    # prepare
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-m",
        "--manager",
        type=str,
        help="Select the manager to use. (pip | conda) default: pip",
        default="pip",
    )
    parser.add_argument("-p", "--plus", help="Use heavy libs too.", action="store_true")
    parser.add_argument(
        "-uni", "--uninstall", help="Change uninstall mode.", action="store_true"
    )

    return parser.parse_args()


def initialize(manager: Literal["pip", "conda"]):
    system(f"{manager} install --upgrade {manager}")
    system(f"{manager} install termcolor")


def rehash():
    """
    Execute `pyenv rehash` when use pyenv.
    To be able to use the installed commands.
    """
    if which("pyenv"):
        print("rehash pyenv...")
        system("pyenv rehash")

    if which("asdf"):
        print("reshim asdf...")
        system("asdf reshim")


def manage_libs(
    manager: Literal["pip", "conda"], mode: Literal["install", "uninstall"], heavy: bool
):
    manage_lib(manager, mode, libs)
    if heavy:
        manage_lib(manager, mode, heavy_libs)


def manage_lib(
    manager: Literal["pip", "conda"],
    mode: Literal["install", "uninstall"],
    libraries: list[dict[str, str]],
):
    for lib in libraries:
        [name, description] = [lib["name"], lib["description"]]

        print(color("Installing ", "green") + f"{name}")
        print(color(f"INFO: {description}", "cyan"))

        if lib["installer"]:
            system(lib["installer"])
            continue
        system(f"{manager} {mode} {name}")

        print("")


def main():
    initialize(manager)
    rehash()

    if uninstall:
        manage_libs(manager, "uninstall", plus)
    else:
        manage_libs(manager, "install", plus)

    rehash()
    print(color("Successes: Finished working on all libraries.", "green"))


if __name__ == "__main__":
    args = get_args()
    manager, plus, uninstall = [args.manager, args.plus, args.uninstall]
    print(f"{manager} has been selected.")
    main()
