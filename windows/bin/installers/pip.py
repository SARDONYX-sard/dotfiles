"""
.EXAMPLE
- Install with manager.
python3 pip.py --manager pip
python3 pip.py --manager conda

- Uninstall global packages.
python3 pip.py --manager pip --uninstall
python3 pip.py --manager conda --Uninstall

.NOTES
- You can install with libraries list(windows\\data\requirements.txt)
pip install -r requirements.txt


- How to output requirements.txt
pip freeze > requirements.txt
"""


import argparse
from os import system
from shutil import which
from typing import Literal


libs = [
    # Formatter & Linter
    {"name": "black", "description": "formatter."},
    {"name": "flake8", "description": "linter."},
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
    # Fortran
    {"name": "fortran-language-server", "description": "Fortran language server."},
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


def colored(
    string: str,
    mode: Literal["black", "green", "red", "yellow", "blue", "magenta", "cyan"],
):
    colors = {
        "black": "\033[30m",
        "red": "\033[31m",
        "green": "\033[32m",
        "yellow": "\033[33m",
        "blue": "\033[34m",
        "magenta": "\033[35m",
        "cyan": "\033[36m",
    }
    return f"{colors[mode]}{string}\033[0m"


def check_python_available():
    if which("python"):
        return True
    print("Python is not available.")
    colored("WARNING: Python is not installed.", "yellow")

    if which("pyenv"):
        print(colored("Found pyenv.", "cyan"))
        print(colored("Trying to install with pyenv...", "cyan"))
        system("pyenv install 3.8.10")

    elif which("scoop"):
        print(colored("Trying to install with scoop...", "cyan"))
        # latest python version (e.g. python3.10)
        system("scoop install python")

    else:
        print(colored("Python cannot installed.", "red"))
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


def rehash():
    """
    Execute `pyenv rehash` when use pyenv.
    To be able to use the installed commands.
    """
    if which("pyenv"):
        print("rehash pyenv...")
        system("pyenv rehash")


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

        print(colored("Installing ", "green") + f"{name}")
        print(colored(f"INFO: {description}", "blue"))

        if lib.get("installer"):
            system(lib["installer"])
            continue
        system(f"{manager} {mode} {name}")
        print("")


def main():
    check_python_available()
    initialize(manager)
    rehash()

    if uninstall:
        manage_libs(manager, "uninstall", plus)
    else:
        manage_libs(manager, "install", plus)

    rehash()
    print(colored("Successes: Finished working on all libraries.", "green"))


if __name__ == "__main__":
    args = get_args()
    manager, plus, uninstall = [args.manager, args.plus, args.uninstall]
    print(f"{manager} has been selected.")
    main()
