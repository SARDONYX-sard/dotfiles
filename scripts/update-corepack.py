"""Corepack latest version updater

Requires:
- python3(e.g. my env 3.10, 3.11)
- ripgrep: https://github.com/BurntSushi/ripgrep
- Nodejs >=16.9.0 or `npm i -g corepack`

Usage:

- activate latest version
python3 update-corepack.py

- dry-run mode
python3 update-corepack.py --dry-run
python3 update-corepack.py -d

- remove all previous versions
python3 update-corepack.py --remove-prev
python3 update-corepack.py -r
"""


import argparse
from os import listdir, system
import os
from pathlib import Path
import subprocess
from typing import Literal


def shell_exec(command: str) -> str:
    """
    Reference https://stackoverflow.com/questions/18739239/python-how-to-get-stdout-after-running-os-system
    """
    return subprocess.getoutput(command)


def corepack_enabled(manager_name: Literal["npm", "yarn", "pnpm"]):
    return shell_exec(f"corepack enabled {manager_name}")


def activate_corepack(manager_name: Literal["npm", "yarn", "pnpm"], version: str):
    system(f"corepack prepare {manager_name}@{version}  --activate")


def get_latest_version(manager_name: Literal["npm", "yarn", "pnpm"], is_debug: bool):
    """Get latest manager version

    Args:
        `manager_name`: Name of the package manager
        `is_debug`: Enable debug mode

    Return:
        latest package manager's version
    """
    version_regexp = "[0-9]?[0-9]\\.[0-9]?[0-9]\\.[0-9]?[0-9]"
    cmd = f'npm search {manager_name} | rg "^{manager_name} .* {version_regexp}" \
| rg -o "{version_regexp}"'

    if is_debug:
        print(color("DEBUG: Execute command ", "cyan") + f"{cmd}")
    return shell_exec(cmd)  # `-o` is ripgrep only match option


def remove(path: Path):
    """
    Remove recursive force
    (To avoid permission error)
    Https://stackoverflow.com/questions/1889597/deleting-directory-in-python
    """
    if os.name == "nt":
        shell_exec(f'powershell.exe Remove-Item -Recurse -Force "{path}"')
    elif os.name == "posix":
        shell_exec(f'/bin/rm -rf "{path}"')


def get_corepack_path():
    if os.name == "nt":
        return Path.joinpath(Path.home(), ".node/corepack")
    else:
        # For Posix
        return Path.joinpath(Path.home(), ".cache/node/corepack")


def remove_prev_versions(
    manager_name: Literal["npm", "yarn", "pnpm"],
    manager_latest_version: str,
    is_debug: bool,
):
    """
    Removes previous versions of the package manager

    `manager_name`
        Name of the package manager
    `manager_latest_version`
        Latest version of the package manager(e.g. 1.22.19)
    `is_debug`
        enable debug info. & not remove
    """
    manager_path = Path.joinpath(get_corepack_path(), manager_name)
    manager_versions = listdir(manager_path)

    if manager_latest_version in manager_versions:
        manager_versions.remove(manager_latest_version)

    if is_debug:
        print(color("DEBUG: version to be removed ...", "cyan"), end="")
        print(manager_versions)
    else:
        print(color("INFO: Removing previous versions...", "cyan"))
        for manager_version in manager_versions:
            remove(Path.joinpath(manager_path, manager_version))


def run_dry_run(manager_name: str):
    search_cmd = f"npm search {manager_name}"
    print(color("DEBUG: Execute command ", "cyan") + f"{search_cmd}", end="\n")
    print(
        f"{search_cmd} Docs: https://docs.npmjs.com/cli/v6/commands/npm-search",
        end="\n",
    )
    system(search_cmd)
    print("\n")


def get_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-d", "--dry-run", help="No activate corepack. just stdout", action="store_true"
    )

    parser.add_argument(
        "-r",
        "--remove-prev",
        help="Remove previous corepack version.",
        action="store_true",
    )

    parser.add_argument(
        "-e", "--enabled", help="Enable management by corepack.", action="store_true"
    )

    return parser.parse_args()


def color(string: str, mode: Literal["green", "red", "yellow", "cyan"]):
    colors = {
        "red": "\033[31m",
        "green": "\033[32m",
        "yellow": "\033[33m",
        "cyan": "\033[36m",
    }
    return f"{colors[mode]}{string}\033[0m"


def main():
    args = get_args()
    managers: list[Literal["npm", "pnpm", "yarn"]] = ["npm", "pnpm", "yarn"]

    if is_dry_run := args.dry_run:
        print(
            color(
                "INFO: Dry run mode enabled.\n\
Please visually check that the version assigned by the code is correct.\n",
                "cyan",
            )
        )

    for manager_name in managers:
        manager_latest_version = get_latest_version(manager_name, is_dry_run)
        print(f"{manager_name}'s latest version:  {manager_latest_version}")

        if args.enabled:
            print(color("INFO: Enabling management by corepack...", "cyan"))
            corepack_enabled(manager_name)

        if args.remove_prev:
            remove_prev_versions(manager_name, manager_latest_version, is_dry_run)

        if is_dry_run:
            run_dry_run(manager_name)

        else:
            print(f"{manager_name} active: {manager_latest_version}")
            activate_corepack(manager_name, manager_latest_version)


if __name__ == "__main__":
    main()
