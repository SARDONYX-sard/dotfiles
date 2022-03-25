#!/usr/bin/env bash

sudo add-apt-repository ppa:avsm/ppa
sudo apt update
sudo apt install opam

echo "Y" | opam init

echo "Y" |
  opam install ocaml-lsp-server \
    dune # buildtool for OCaml(https://github.com/ocaml/dune)
