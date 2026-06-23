#!/usr/bin/env bash
# Arch Linux setup - installs from packages/

set -euo pipefail

if [ "$(uname -s)" != "Linux" ]; then
  echo "⊘ skip: not Linux"
  exit 0
fi

if [ ! -f /etc/arch-release ]; then
  echo "⊘ skip: not Arch Linux"
  exit 0
fi

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
PACKAGE_DIR="$DOTFILES_DIR/packages"

section() { echo; echo "━━━ $1 ━━━"; }

read_package_list() {
  local file="$PACKAGE_DIR/$1"
  if [ ! -f "$file" ] || [ ! -s "$file" ]; then
    echo "⊘ skip: packages/$1 not found or empty" >&2
    return 1
  fi
  grep -v '^$' "$file" | grep -v '^#' || true
}

install_base_deps() {
  section "Base deps (git)"
  sudo pacman -S --needed --noconfirm git
  echo "✓ base deps ready"
}

ensure_archlinuxcn_repo() {
  section "archlinuxcn repository"

  local pacman_conf="/etc/pacman.conf"

  if grep -Eq '^\[archlinuxcn\]' "$pacman_conf"; then
    echo "✓ already configured"
  else
    echo "→ enabling archlinuxcn in $pacman_conf..."
    printf '\n# dotfiles: archlinuxcn repository\n[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch\n' | sudo tee -a "$pacman_conf" >/dev/null
    echo "✓ repository added"
  fi

  echo "→ installing archlinuxcn keyring..."
  sudo pacman -Sy --needed --noconfirm archlinuxcn-keyring
  echo "✓ archlinuxcn ready"
}

install_pacman_packages() {
  section "pacman packages"

  local packages_str
  packages_str="$(read_package_list arch/pacman.txt)" || return 0

  local packages=()
  local entry

  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    packages+=("$entry")
  done <<< "$packages_str"

  if [ "${#packages[@]}" -gt 0 ]; then
    while IFS= read -r pkg; do
      [ -n "$pkg" ] && packages+=("$pkg")
    done < <(printf '%s\n' "${packages[@]}" | sort -u)
  fi

  if [ "${#packages[@]}" -eq 0 ]; then
    echo "⊘ no packages to install"
    return 0
  fi

  echo "→ ${#packages[@]} package(s) to check"

  local missing=()
  for pkg in "${packages[@]}"; do
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg"
    else
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing ${#missing[@]} package(s): ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi

  echo "✓ pacman packages ready (${#packages[@]} total)"
}

install_archlinuxcn_packages() {
  section "archlinuxcn packages"

  local packages_str
  packages_str="$(read_package_list arch/archlinuxcn.txt)" || return 0

  local packages=()
  local entry

  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    packages+=("$entry")
  done <<< "$packages_str"

  if [ "${#packages[@]}" -eq 0 ]; then
    echo "⊘ no archlinuxcn packages to install"
    return 0
  fi

  local missing=()
  local pkg
  for pkg in "${packages[@]}"; do
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg"
    else
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing ${#missing[@]} archlinuxcn package(s): ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi

  echo "✓ archlinuxcn packages ready (${#packages[@]} total)"
}

install_aur_packages() {
  section "AUR packages"

  local packages_str
  packages_str="$(read_package_list arch/aur.txt)" || return 0

  local aur_helper=""
  if command -v paru >/dev/null 2>&1; then
    aur_helper="paru"
  elif command -v yay >/dev/null 2>&1; then
    aur_helper="yay"
  fi

  local packages=()
  local missing=()
  local pkg

  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    packages+=("$pkg")
  done <<< "$packages_str"

  if [ "${#packages[@]}" -eq 0 ]; then
    echo "⊘ no AUR packages listed"
    return 0
  fi

  if [ -z "$aur_helper" ]; then
    echo "⊘ skip: AUR packages listed, but no AUR helper found"
    echo "  Install paru or yay through a package-managed path you trust, then re-run this script."
    echo "  This repository does not build AUR helpers from source."
    return 0
  fi

  echo "→ using AUR helper: $aur_helper"

  for pkg in "${packages[@]}"; do
    if "$aur_helper" -Qi "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg"
    else
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing ${#missing[@]} AUR package(s): ${missing[*]}"
    "$aur_helper" -S --needed --noconfirm "${missing[@]}"
  fi

  echo "✓ AUR packages ready (${#packages[@]} total)"
}

configure_zsh() {
  section "Default shell"

  if [ "$(basename "$SHELL")" = "zsh" ]; then
    echo "✓ default shell is already zsh"
    return
  fi

  echo "→ changing default shell to zsh..."
  chsh -s /usr/bin/zsh
  echo "✓ switched (restart session to apply)"
}

install_tmux_plugins() {
  section "tmux plugins"

  local tpm_path=""
  [ -f /usr/share/tmux-plugin-manager/tpm ] && tpm_path="/usr/share/tmux-plugin-manager"
  [ -z "$tpm_path" ] && [ -f "$HOME/.tmux/plugins/tpm/tpm" ] && tpm_path="$HOME/.tmux/plugins/tpm"

  if [ -z "$tpm_path" ]; then
    echo "⊘ skip: tpm not found (install tmux-plugin-manager through paru/yay, then re-run)"
    return 0
  fi

  echo "→ installing plugins via tpm ($tpm_path)..."
  local session_name="_tpm_install_$$"
  tmux start-server
  tmux new-session -d -s "$session_name" 2>/dev/null || true
  tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
  export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/"
  "$tpm_path/bin/install_plugins"
  tmux kill-session -t "$session_name" 2>/dev/null || true
  echo "✓ tmux plugins installed"
}

install_mise_tools() {
  section "mise dev tools"

  if ! command -v mise >/dev/null 2>&1; then
    echo "⊘ skip: mise not found"
    return 0
  fi

  echo "→ installing tools from ~/.config/mise/config.toml..."
  mise install
  echo "✓ mise tools ready"
}

print_summary() {
  section "Post-install"
  cat <<'EOF'
  1. Restart session / log out & back in for:
       - Default shell → zsh
       - ~/.zshrc to take effect

  2. WezTerm is configured via ~/.config/wezterm/wezterm.lua
     (symlinked from dotfiles). Restart WezTerm if already open.

  3. Enable and start Tailscale:
       sudo systemctl enable --now tailscaled
       sudo tailscale up
EOF
}

install_base_deps
ensure_archlinuxcn_repo
install_archlinuxcn_packages
install_pacman_packages
install_aur_packages
install_tmux_plugins
install_mise_tools
configure_zsh
print_summary
