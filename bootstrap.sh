#!/usr/bin/env bash
# Bootstrap script for fresh machine setup
# Run this AFTER cloning the dotfiles repo

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
export DOTFILES_DIR

section() { echo; echo "━━━ $1 ━━━"; }

usage() {
  cat <<EOF
Usage: $0 [-d] [-f] [-h]

Setup a fresh machine from dotfiles snapshots.

  -d  Dry run (preview what would be installed)
  -f  Force overwrite existing configs
  -h  Help

Prerequisites:
  Arch Linux: sudo pacman -S git base-devel
  macOS:      xcode-select --install

Then:
  git clone <this-repo> ~/dotfiles
  cd ~/dotfiles
  ./bootstrap.sh
EOF
  exit 0
}

VERIFY_OPTS=""
while getopts "dfh" opt; do
  case "$opt" in
    d) VERIFY_OPTS="$VERIFY_OPTS -d" ;;
    f) VERIFY_OPTS="$VERIFY_OPTS -f" ;;
    *) usage ;;
  esac
done

section "Pre-flight checks"

echo "Dotfiles dir: $DOTFILES_DIR"

if [ ! -d "$DOTFILES_DIR/snapshots" ]; then
  echo "✗ snapshots/ directory not found"
  echo "  Run ./scripts/snapshot.sh on your current machine first."
  exit 1
fi

snapshot_count="$(find "$DOTFILES_DIR/snapshots" -name '*.txt' -size +0c 2>/dev/null | wc -l)"
if [ "$snapshot_count" -eq 0 ]; then
  echo "✗ no snapshot files found in snapshots/"
  echo "  Run ./scripts/snapshot.sh on your current machine first."
  exit 1
fi

echo "✓ found $snapshot_count snapshot file(s):"
find "$DOTFILES_DIR/snapshots" -name '*.txt' -size +0c -exec basename {} \; 2>/dev/null | sort | sed 's/^/    /'

section "Confirm"

case "$(uname -s)" in
  Linux)
    if [ -f /etc/arch-release ]; then
      echo "OS: Arch Linux"
    else
      echo "OS: Linux (non-Arch, limited support)"
    fi
    ;;
  Darwin)
    echo "OS: macOS"
    ;;
  *)
    echo "OS: $(uname -s) (unsupported)"
    exit 1
    ;;
esac

echo
echo "This will:"
echo "  1. Install all packages from snapshots/"
echo "  2. Symlink config files to ~/.config and ~/"
echo "  3. Configure system settings (shell, input method, etc.)"
echo
read -rp "Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

section "Running installer"

# shellcheck disable=SC2086
"$DOTFILES_DIR/install.sh" $VERIFY_OPTS

section "Done"
echo
echo "All done! Restart your shell or log out/in to apply all changes."
