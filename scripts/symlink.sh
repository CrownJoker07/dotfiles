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

case "$(uname -s)" in
  Darwin) OS_NAME="macos" ;;
  Linux) OS_NAME="linux" ;;
  *)
    echo "✗ unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

section() { echo; echo "━━━ $1 ━━━"; }

is_repo_path() {
  case "$1" in
    "$DOTFILES_DIR"/*) return 0 ;;
    *) return 1 ;;
  esac
}

replace_link() {
  local src="$1" dst="$2"

  if [ "$DRY_RUN" = true ]; then
    echo "↻ would relink: $dst -> $src"
  else
    ln -sfn "$src" "$dst" || { echo "✗ error: failed to relink $dst"; return 1; }
    echo "↻ relinked: $dst -> $src"
  fi
}

ensure_real_dir() {
  local dir="$1"
  local target

  if [ -L "$dir" ]; then
    target="$(readlink "$dir" 2>/dev/null || true)"
    if is_repo_path "$target"; then
      if [ "$DRY_RUN" = true ]; then
        echo "↻ would replace dir link with directory: $dir"
      else
        rm "$dir"
        mkdir -p "$dir"
        echo "↻ replaced dir link with directory: $dir"
      fi
      return 0
    fi
  fi

  [ "$DRY_RUN" = false ] && mkdir -p "$dir"
  return 0
}

link_item() {
  local src="$1" dst="$2"
  local target

  [ ! -e "$src" ] && { echo "⊘ skip (not found): $src"; return 0; }
  [ "$DRY_RUN" = false ] && mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    target="$(readlink "$dst" 2>/dev/null || true)"
    [ "$target" = "$src" ] && { echo "✓ already linked: $dst"; return 0; }

    if is_repo_path "$target" && is_repo_path "$src"; then
      replace_link "$src" "$dst"
      return 0
    fi
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

prepare_tree_dirs() {
  local src_root="$1" dst_root="$2"
  local src_dir rel dst_dir

  [ ! -d "$src_root" ] && return 0

  while IFS= read -r src_dir; do
    rel="${src_dir#"$src_root"}"
    rel="${rel#/}"
    [ -z "$rel" ] && continue
    dst_dir="$dst_root/$rel"
    ensure_real_dir "$dst_dir"
  done < <(find "$src_root" -type d | sort)
}

link_tree_files() {
  local src_root="$1" dst_root="$2"
  local src rel dst

  if [ ! -d "$src_root" ]; then
    echo "⊘ skip tree (not found): $src_root"
    return 0
  fi

  prepare_tree_dirs "$src_root" "$dst_root"

  while IFS= read -r src; do
    rel="${src#"$src_root"/}"
    dst="$dst_root/$rel"
    link_item "$src" "$dst"
  done < <(find "$src_root" -type f | sort)

  find "$dst_root" -xtype l 2>/dev/null | while IFS= read -r stale; do
    target="$(readlink "$stale" 2>/dev/null || true)"
    if is_repo_path "$target"; then
      if [ "$DRY_RUN" = true ]; then
        echo "✗ would remove stale link: $stale"
      else
        rm "$stale" && echo "✗ removed stale link: $stale"
      fi
    fi
  done
}

echo "OS: $OS_NAME"

section "Base config"
link_tree_files "$DOTFILES_DIR/config/base" "$XDG_CONFIG_DIR"

section "$OS_NAME config"
link_tree_files "$DOTFILES_DIR/config/$OS_NAME" "$XDG_CONFIG_DIR"

section "Base home"
link_tree_files "$DOTFILES_DIR/home/base" "$HOME"

section "$OS_NAME home"
link_tree_files "$DOTFILES_DIR/home/$OS_NAME" "$HOME"
