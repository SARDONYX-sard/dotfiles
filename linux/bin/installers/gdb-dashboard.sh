#!/usr/bin/env bash

function check_deps() {
  local deps_array=(
    "curl"
  )

  local no_deps="false"

  for dep in "${deps_array[@]}"; do
    (command -v "${dep}") >/dev/null 2>&1 && printf "%s not found" dep && no_deps="true"
  done

  [ $no_deps == "true" ] && exit 1
}
check_deps

curl -sSfL https://git.io/.gdbinit \ -o "${HOME}"/.gdbinit
