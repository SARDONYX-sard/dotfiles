"""
# Examples

- Remove all cache
    python3 remove-cache.py

- Remove all cache add blacklist
    python3 remove-cache.py --blacklist "npm,go"
"""

import argparse
from os import system
from shutil import which
import sys
from typing import Literal


libs = [
    # Utils
    {"name": "cargo", "command": "cargo cache --autoclean"},
    {"name": "go", "command": "go clean --modcache"},
    {"name": "npm", "command": "npm cache verify"},
    {"name": "pnpm", "command": "pnpm store prune"},
    {"name": "yarn", "command": "yarn cache clean"},
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
    color(
        "WARNING: Python is not installed.\
\n Please install Python before running this.",
        "yellow",
    )
    sys.exit(-1)


def libs_cmd_exec(
    libraries: list[dict[str, str]],
    blacklist: list[str] | None = None,
    is_debug: bool = False,
):
    if blacklist is None:
        blacklist = []
    for lib in libraries:
        [name, command] = [lib["name"], lib["command"]]
        name_title = color("Name", "green")

        print(83 * "-")
        print(f"{name_title}: {name}")

        if is_debug:
            print(f"execute command: {command}")
            continue
        if which(name) is None:
            continue

        if name not in blacklist:
            print(color("Cleaning cache...", "cyan"))
            system(command)
        print("")


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-b",
        "--blacklist",
        help='List of command names that do not delete cache. e.g. "npm,go"',
        type=str,
    )

    parser.add_argument(
        "-d",
        "--dry-run",
        help="Run debug mode. Not remove caches.",
        action="store_true",
    )

    return parser.parse_args()


def main():
    args = get_args()
    black_list = list(args.blacklist.split(","))
    libs_cmd_exec(libs, black_list, args.dry_run)
    print(color("Successes: Finished working on all libraries.", "green"))


if __name__ == "__main__":
    main()
