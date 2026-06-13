#!/usr/bin/env bash
# Arch Linux setup - installs from snapshots/

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
SNAPSHOT_DIR="$DOTFILES_DIR/snapshots"

section() { echo; echo "━━━ $1 ━━━"; }

read_snapshot() {
  local file="$SNAPSHOT_DIR/$1"
  if [ ! -f "$file" ] || [ ! -s "$file" ]; then
    echo "⊘ skip: snapshots/$1 not found or empty" >&2
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

  local packages_str
  packages_str="$(read_snapshot pacman.txt)" || return 0

  local packages=()
  local missing=()
  local pkg

  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    packages+=("$pkg")
  done <<< "$packages_str"

  if [ "${#packages[@]}" -eq 0 ]; then
    echo "⊘ no packages listed"
    return 0
  fi

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

install_aur_packages() {
  section "AUR packages (yay)"

  local packages_str
  packages_str="$(read_snapshot aur.txt)" || return 0

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
  pkgs_str="$(read_snapshot npm-global.txt)" || return 0

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
  tools_str="$(read_snapshot dotnet-tools.txt)" || return 0

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
  apps_str="$(read_snapshot flatpak.txt)" || return 0

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

init_rustup() {
  section "rustup"

  if ! command -v rustup >/dev/null 2>&1; then
    echo "⊘ skip: rustup not installed"
    return 0
  fi

  if command -v rustc >/dev/null 2>&1; then
    echo "✓ rustup already initialized: $(rustc --version)"
    return 0
  fi

  echo "→ initializing rustup..."
  rustup-init -y --no-modify-path
  echo "✓ rustup initialized"
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

print_summary() {
  section "Post-install"
  cat <<'EOF'
  1. Restart session / log out & back in for:
       - Default shell → zsh
       - ~/.zshrc to take effect
       - fcitx5 environment variables

  2. Open Konsole → verify:
       - Font: JetBrainsMono Nerd Font
       - Color scheme: catppuccin-mocha
       - Or use the "JetBrains" profile

  3. If rustup was just initialized, restart your shell.

  4. If dotnet-sdk was just installed, restart your shell then
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
configure_fcitx5
init_rustup
configure_zsh
print_summary
