"""
.SYNOPSIS
Install nodejs-lts and global libraries

.DESCRIPTION
Install nodejs-lts and global libraries.

.EXAMPLE
# Install libraries.
nodejs.ps1 -Manager npm
nodejs.ps1 -Manager yarn
nodejs.ps1 -Manager pnpm

# Uninstall libraries.
nodejs.ps1 -Manager npm -Uninstall
nodejs.ps1 -Manager yarn -Uninstall
nodejs.ps1 -Manager pnpm -Uninstall
"""


import argparse
from os import system
import re
from shutil import which
import subprocess
import sys
from typing import Literal


libs = [
    # Basic
    {"name": "nexe", "description": "exe generator."},
    {"name": "npm-check-updates", "description": "Check for outdated dependencies."},
    {
        "name": "license-checker",
        "description": "Automated auditing, performance metrics.",
    },
    # Optimization
    {
        "name": "svgo",
        "description": "A Node.js-based tool for optimizing SVG.",
    },  # For update libs
    {
        "name": "conventional-changelog-cli",
        "description": "Generate a changelog from git metadata.",
    },
    {"name": "lighthouse", "description": "Find newer versions of dependencies."},
    {
        "name": "webpack-bundle-size-analyzer",
        "description": "Analyze your webpack bundle size.",
    },
    # Code linter
    {"name": "eslint", "description": "An AST-based pattern checker for JavaScript."},
    {
        "name": "prettier",
        "description": "An opinionated code formatter",
    },  # Replacement of existing commands
    # Commands
    {"name": "zx", "description": "A tool for writing better scripts."},  # Transpiler
    {"name": "typescript", "description": "Super set of JS."},
    {"name": "ts-node", "description": "TypeScript execution environment."},
    {
        "name": "assemblyscript",
        "description": "Definitely not a TypeScript to WebAssembly compiler.",
    },
]


def color(string: str, mode: Literal["green", "red", "yellow", "cyan"]):
    colors = {
        "red": "\033[31m",
        "green": "\033[32m",
        "yellow": "\033[33m",
        "cyan": "\033[36m",
    }
    return f"{colors[mode]}{string}\033[0m"


def command(command: str) -> str:
    """
    Reference https://stackoverflow.com/questions/18739239/python-how-to-get-stdout-after-running-os-system
    """
    return subprocess.getoutput(command)


# --------------------------------------------------------------------------------------------------
# Installer functions
# --------------------------------------------------------------------------------------------------


def check_nodejs_available():
    if which("node"):
        return True
    print("Nodejs is not available.")
    print(
        color(
            "WARNING: Nodejs is not installed.\n Please Nodejs install  before running this.",
            "yellow",
        )
    )
    print(
        "You can install it in one of the following ways. \
\
Manually install: \
    Go to https: // nodejs.org\
\
    LTS version with longer security support is recommended.\
\
\
Install with Scoop:\
    Execute the following commands.↓\
\
    Invoke - WebRequest - useb get.scoop.sh | Invoke - Expression\
    scoop install nodejs - lts"
    )
    sys.exit(-1)


def get_args():
    # prepare
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-m",
        "--manager",
        type=str,
        help="Select the manager to use. (npm|yarn|pnpm) default: npm",
        default="npm",
    )
    parser.add_argument(
        "-uni", "--uninstall", action="store_true", help="Change uninstall mode."
    )
    parser.add_argument(
        "-d",
        "--dry-run",
        action="store_true",
        help="Dryrun mode. (default: False)\
\
What is `dryrun` ?\
    A mode in which the user `does not execute commands`\
    but only prints commands being executed.\
",
    )

    return parser.parse_args()


def initialize(manager: Literal["npm", "yarn", "pnpm"]):
    """Update packages database"""

    current_node_version = command("node -v")
    print(f"Current node version: {current_node_version}")

    # We dare to use [0-9]
    # because \d in python is not equivalent to [0-9] but wider.
    version_regexp = re.compile("([0-9]?[0-9]\\.[0-9]?[0-9])\\.[0-9]?[0-9]")
    node_version_array = version_regexp.search(current_node_version)
    if node_version_array is None:
        print(color("Err! Failed to get node versions", "red"))
        return

    node_version = float(node_version_array[1])

    if node_version >= 14.19:
        print(color(f"Enable Corepack to use {manager} ...", "green"))
        command("corepack enable npm")
    else:
        print("Nodejs is older than v14.19.0")
        command(f"npm i -g ${manager}")


def manage_libs(
    manager: Literal["npm", "yarn", "pnpm"], mode: Literal["install", "uninstall"]
):
    """
    Install or uninstall libraries.
    """
    prefix = f"{manager} {mode} -g"
    manage_lib(prefix, libs)


def manage_lib(prefix: str, libraries: list[dict[str, str]]):
    for lib in libraries:
        [name, description] = [lib["name"], lib["description"]]
        name_title = color("       Name", "green")
        description_title = color("Description", "cyan")

        print(
            "-----------------------------------------------------------------------------------"
        )
        print(f"{name_title}: {name}")
        print(f"{description_title}: {description}")

        if "installer" in lib:
            system(lib["installer"])
            continue

        if dry_run:
            command_title = color("    Command", "yellow")
            print(f"{command_title}: {prefix} {name}")
        else:
            system(f"{prefix} {name}")
        print("")


def main():
    if dry_run:
        print(color("DebugInfo: Start dry_run.", "cyan"))

    print(f"{manager} has been selected.")
    initialize(manager)

    if uninstall:
        manage_libs(manager, "uninstall")
    else:
        manage_libs(manager, "install")

    print(color("Successes: Finished working on all libraries.", "green"))
    if dry_run:
        print(color("DebugInfo: Exit dry_run.", "cyan"))


if __name__ == "__main__":
    args = get_args()
    manager, uninstall, dry_run = [args.manager, args.uninstall, args.dry_run]
    main()
