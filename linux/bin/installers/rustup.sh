#!/usr/bin/env bash

#? With rustup, you can put a .rust-toolchain file in your project
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "It is recommended to install the procs command instead of ps.
In that case, please enter the following command.

    cargo install procs;
    cargo install exa;
"
