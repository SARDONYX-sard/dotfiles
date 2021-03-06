"""Corepack latest version updater

Requires:
- python3
- ripgrep: https://github.com/BurntSushi/ripgrep
- Nodejs >=16.9.0 or `npm i -g corepack`

Usage:

- activate latest version
python3 corepack-update.py

- dry-run mode
python3 corepack-update.py --dry-run
python3 corepack-update.py -d

- remove previous version
python3 corepack-update.py --remove
"""


import argparse
from os import system
import subprocess
from typing import Literal


def system_call(command: str) -> str:
    """
    Reference https://stackoverflow.com/questions/18739239/python-how-to-get-stdout-after-running-os-system
    """
    return subprocess.getoutput(command)


def corepack_enabled(manager_name: str):
    return system_call(f"corepack enabled {manager_name}")


def activate_corepack(manager_name: str, version: str):
    system(f"corepack prepare {manager_name}@{version}  --activate")


def get_latest_version(manager_name: str, is_debug: bool):
    version_regexp = "[0-9]?[0-9]\\.[0-9]?[0-9]\\.[0-9]?[0-9]"
    cmd = f"npm search {manager_name} | rg \"^{manager_name} .* {version_regexp}\" \
| rg -o \"{version_regexp}\""

    if is_debug:
        print(color("Execute command", "cyan") + f": {cmd}")
    return system_call(cmd)  # `-o` is ripgrep only match option


def remove_previous_versions(manager_name: str):
    print(color("INFO: Removing previous versions...", "cyan"))
    previous_version = system_call(f"{manager_name} -v")
    system(f"corepack disable {manager_name} {previous_version}")


def run_dry_run(manager_name: str):
    search_cmd = f"npm search {manager_name}"
    print(color("Execute command", "cyan") + f": {search_cmd}")
    print(
        f"{search_cmd} Docs: https://docs.npmjs.com/cli/v6/commands/npm-search")
    system(search_cmd)
    print("\n")


def get_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-d",
        "--dry-run",
        help="No activate corepack. just stdout",
        action="store_true")

    parser.add_argument(
        "-r",
        "--remove",
        help="Remove previous corepack version.",
        action="store_true")

    parser.add_argument(
        "-e",
        "--enabled",
        help="Enable management by corepack.",
        action="store_true")

    return (parser.parse_args())


def color(string: str, mode: Literal["green", "red", "yellow", "cyan"]):
    colors = {
        "red": "\033[31m",
        "green": "\033[32m",
        "yellow": "\033[33m",
        "cyan": "\033[36m"}
    return f'{colors[mode]}{string}\033[0m'


def main():
    args = get_args()
    managers = ["npm", "pnpm", "yarn"]

    if is_dry_run := args.dry_run:
        print(color("INFO: Dry run mode enabled.\n\
Please visually check that the version assigned by the code is correct.\n", "cyan"))

    for manager_name in managers:
        manager_latest_version = get_latest_version(manager_name, is_dry_run)

        if args.enabled:
            print(color("INFO: Enabling management by corepack...", "cyan"))
            corepack_enabled(manager_name)

        if not is_dry_run and args.remove:
            remove_previous_versions(manager_name)

        if is_dry_run:
            print(
                f"Probably... the latest {manager_name} version: {manager_latest_version}")

            run_dry_run(manager_name)
        else:
            print(f"{manager_name} active: {manager_latest_version}")
            activate_corepack(manager_name, manager_latest_version)


if __name__ == "__main__":
    main()
