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

read_snapshot() {
  local file="$PACKAGE_DIR/$1"
  if [ ! -f "$file" ] || [ ! -s "$file" ]; then
    echo "⊘ skip: packages/$1 not found or empty" >&2
    return 1
  fi
  grep -v '^$' "$file" | grep -v '^#' || true
}

install_base_deps() {
  section "Base deps (git, base-devel)"
  sudo pacman -S --needed --noconfirm git base-devel
  echo "✓ base deps ready"
}

install_yay() {
  section "yay (AUR helper)"
  if command -v yay >/dev/null 2>&1; then
    echo "✓ already installed: $(yay --version | head -1)"
    return
  fi

  echo "→ building from AUR..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
  )
  rm -rf "$tmpdir"

  if command -v yay >/dev/null 2>&1; then
    echo "✓ yay installed"
  else
    echo "✗ yay install failed"
    exit 1
  fi
}

install_pacman_packages() {
  section "pacman packages"

  local snapshot_str
  snapshot_str="$(read_snapshot arch/pacman.txt)" || return 0

  local packages=()
  local entry

  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    packages+=("$entry")
  done <<< "$snapshot_str"

  local unique_packages=()
  if [ "${#packages[@]}" -gt 0 ]; then
    while IFS= read -r pkg; do
      [ -n "$pkg" ] && unique_packages+=("$pkg")
    done < <(printf '%s\n' "${packages[@]}" | sort -u)
  fi

  if [ "${#unique_packages[@]}" -eq 0 ]; then
    echo "⊘ no packages to install"
    return 0
  fi

  echo "→ ${#unique_packages[@]} package(s) to check"

  local missing=()
  for pkg in "${unique_packages[@]}"; do
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

  echo "✓ pacman packages ready (${#unique_packages[@]} total)"
}

install_aur_packages() {
  section "AUR packages (yay)"

  local packages_str
  packages_str="$(read_snapshot arch/aur.txt)" || return 0

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

  for pkg in "${packages[@]}"; do
    if yay -Qi "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg"
    else
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing ${#missing[@]} AUR package(s): ${missing[*]}"
    yay -S --needed --noconfirm "${missing[@]}"
  fi

  echo "✓ AUR packages ready (${#packages[@]} total)"
}

install_npm_globals() {
  section "npm global packages"

  if ! command -v npm >/dev/null 2>&1; then
    echo "⊘ skip: npm not available"
    return 0
  fi

  local pkgs_str
  pkgs_str="$(read_snapshot shared/npm-global.txt)" || return 0

  local pkg
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    if npm list -g "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg"
    else
      echo "→ installing $pkg..."
      npm install -g "$pkg"
    fi
  done <<< "$pkgs_str"

  echo "✓ npm globals ready"
}

install_dotnet_tools() {
  section ".NET global tools"

  export PATH="$HOME/.dotnet/tools:$PATH"

  if ! command -v dotnet >/dev/null 2>&1; then
    echo "⊘ skip: dotnet not available (restart shell if just installed)"
    return 0
  fi

  local tools_str
  tools_str="$(read_snapshot shared/dotnet-tools.txt)" || return 0

  local tool
  while IFS= read -r tool; do
    [ -z "$tool" ] && continue
    if command -v "$tool" >/dev/null 2>&1; then
      echo "✓ $tool"
    else
      echo "→ installing $tool..."
      dotnet tool install -g "$tool" || echo "⊘ $tool install failed"
    fi
  done <<< "$tools_str"

  echo "✓ .NET tools ready"
}

install_flatpak_apps() {
  section "Flatpak apps"

  if ! command -v flatpak >/dev/null 2>&1; then
    echo "⊘ skip: flatpak not installed"
    return 0
  fi

  local apps_str
  apps_str="$(read_snapshot arch/flatpak.txt)" || return 0

  local app
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    if flatpak info "$app" >/dev/null 2>&1; then
      echo "✓ $app"
    else
      echo "→ installing $app..."
      flatpak install -y flathub "$app" || echo "⊘ $app install failed"
    fi
  done <<< "$apps_str"

  echo "✓ flatpak apps ready"
}

configure_fcitx5() {
  section "fcitx5 input method"

  if ! pacman -Qi fcitx5 >/dev/null 2>&1; then
    echo "⊘ skip: fcitx5 not installed"
    return 0
  fi

  local env_file="/etc/environment.d/fcitx5.conf"
  local env_content="GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx"

  if [ -f "$env_file" ] && grep -q "GTK_IM_MODULE=fcitx" "$env_file"; then
    echo "✓ fcitx5 env already configured"
    return 0
  fi

  echo "→ writing $env_file..."
  echo "$env_content" | sudo tee "$env_file" >/dev/null
  echo "✓ fcitx5 env configured (restart session to apply)"
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
    echo "✗ tpm not found (install tmux-plugin-manager via AUR)"
    return 1
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

print_summary() {
  section "Post-install"
  cat <<'EOF'
  1. Restart session / log out & back in for:
       - Default shell → zsh
       - ~/.zshrc to take effect
       - fcitx5 environment variables

  2. WezTerm is configured via ~/.config/wezterm/wezterm.lua
     (symlinked from dotfiles). Restart WezTerm if already open.

  3. If dotnet-sdk was just installed, restart your shell then
     re-run this script to install .NET tools.
EOF
}

install_base_deps
install_yay
install_pacman_packages
install_aur_packages
install_npm_globals
install_dotnet_tools
install_flatpak_apps
install_tmux_plugins
configure_fcitx5
configure_zsh
print_summary
