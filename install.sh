#!/usr/bin/env bash
# Dotfiles installer - main entry point

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
XDG_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DRY_RUN=false
export DOTFILES_DIR XDG_CONFIG_DIR

if [ "$#" -ne 0 ]; then
  echo "Usage: $0"
  exit 1
fi

echo "Select install mode:"
echo "  1) Install (backup and replace existing files)"
echo "  2) Preview (backup and replace existing files)"
while true; do
  IFS= read -r -n 1 -p "Enter 1 or 2: " INSTALL_MODE
  echo
  case "$INSTALL_MODE" in
    1) break ;;
    2) DRY_RUN=true; break ;;
    *) echo "Invalid selection." ;;
  esac
done

echo "Dotfiles dir: $DOTFILES_DIR"
echo "Config dir:   $XDG_CONFIG_DIR"
echo

SYMLINK_ARGS=("-f")
[ "$DRY_RUN" = true ] && SYMLINK_ARGS+=("-d")
"$DOTFILES_DIR/scripts/symlink.sh" "${SYMLINK_ARGS[@]}"

INSTALL_STATUS=0
if [ "$DRY_RUN" = true ]; then
  echo "⊘ dry-run: skip package installers"
else
  case "$(uname -s)" in
    Darwin) "$DOTFILES_DIR/scripts/install-macos.sh" || INSTALL_STATUS=$? ;;
    Linux) "$DOTFILES_DIR/scripts/install-arch.sh" || INSTALL_STATUS=$? ;;
    *) echo "⊘ skip package installers: unsupported OS $(uname -s)" ;;
  esac
fi

echo
if [ "$INSTALL_STATUS" -eq 0 ]; then
  echo "Done."
else
  echo "Done with package installer errors."
fi

exit "$INSTALL_STATUS"
