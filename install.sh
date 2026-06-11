#!/usr/bin/env bash
# Dotfiles installer - main entry point

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
XDG_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
export DOTFILES_DIR XDG_CONFIG_DIR

usage() { echo "Usage: $0 [-d] [-f] [-h]\n  -d  Dry run\n  -f  Force overwrite\n  -h  Help"; exit 0; }

while getopts "dfh" opt; do
  case "$opt" in d) DRY_RUN=true ;; f) FORCE=true ;; *) usage ;; esac
done

echo "Dotfiles dir: $DOTFILES_DIR"
echo "Config dir:   $XDG_CONFIG_DIR"
echo

"$DOTFILES_DIR/scripts/install-macos.sh"
"$DOTFILES_DIR/scripts/symlink.sh" "$@"

echo
echo "Done."
