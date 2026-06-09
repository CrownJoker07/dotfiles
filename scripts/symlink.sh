#!/usr/bin/env bash
# Dotfiles symlink creator

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
XDG_CONFIG_DIR="${XDG_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}"
DRY_RUN=false
FORCE=false

usage() { echo "Usage: $0 [-d] [-f] [-h]\n  -d  Dry run\n  -f  Force overwrite\n  -h  Help"; exit 0; }

while getopts "dfh" opt; do
  case "$opt" in d) DRY_RUN=true ;; f) FORCE=true ;; *) usage ;; esac
done

link_item() {
  local src="$1" dst="$2"

  [ ! -e "$src" ] && { echo "⊘ skip (not found): $src"; return 0; }
  [ "$DRY_RUN" = false ] && mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    [ "$(readlink "$dst" 2>/dev/null || true)" = "$src" ] && { echo "✓ already linked: $dst"; return 0; }
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$FORCE" = false ]; then
      echo "⊘ exists, skip: $dst (use -f to backup)"
      return 0
    fi
    local bak="${dst}.bak.$(date +"%Y%m%d_%H%M%S")"
    if [ "$DRY_RUN" = true ]; then
      echo "↻ would backup: $dst -> $bak"
    else
      mv "$dst" "$bak" && echo "↻ backup: $dst -> $bak"
    fi
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "+ would link: $dst -> $src"
  else
    ln -s "$src" "$dst" || { echo "✗ error: failed to link $dst"; return 1; }
    echo "✓ linked: $dst -> $src"
  fi
}

link_item "$DOTFILES_DIR/config/nvim"      "$XDG_CONFIG_DIR/nvim"
link_item "$DOTFILES_DIR/config/alacritty" "$XDG_CONFIG_DIR/alacritty"
link_item "$DOTFILES_DIR/config/lazygit"   "$XDG_CONFIG_DIR/lazygit"
link_item "$DOTFILES_DIR/home/.tmux.conf"  "$HOME/.tmux.conf"
link_item "$DOTFILES_DIR/home/.gitconfig"  "$HOME/.gitconfig"
link_item "$DOTFILES_DIR/home/.zshrc"      "$HOME/.zshrc"
