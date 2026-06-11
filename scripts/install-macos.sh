#!/usr/bin/env bash
# macOS setup - installs Homebrew and all tool dependencies

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "⊘ skip: not macOS"
  exit 0
fi

section() { echo; echo "━━━ $1 ━━━"; }

install_xcode_clt() {
  section "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    echo "✓ already installed"
    return
  fi
  echo "→ installing (a dialog will appear)..."
  xcode-select --install
  echo "  waiting for installation to complete..."
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  echo "✓ installed"
}

install_homebrew() {
  section "Homebrew"
  if command -v brew >/dev/null 2>&1; then
    echo "✓ already installed: $(brew --prefix)"
    return
  fi
  echo "→ installing..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "✓ installed: $(brew --prefix)"
}

install_brew_packages() {
  section "Brew packages"

  local formulae=(neovim git tmux fzf ripgrep lazygit stylua shfmt node rustup)
  local missing=()
  local formula

  for formula in "${formulae[@]}"; do
    if brew list --formula "$formula" >/dev/null 2>&1; then
      echo "✓ $formula already installed"
    else
      missing+=("$formula")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing: ${missing[*]}"
    brew install "${missing[@]}"
  fi

  if command -v alacritty >/dev/null 2>&1 || brew list --cask alacritty >/dev/null 2>&1; then
    echo "✓ alacritty already installed"
  else
    echo "→ installing: alacritty"
    brew install --cask alacritty
  fi

  echo "✓ brew packages ready"
}

jetbrains_nerd_font_available() {
  local dir font

  for dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
    [ -d "$dir" ] || continue
    for font in "$dir"/JetBrainsMono*NerdFont*.ttf; do
      [ -e "$font" ] && return 0
    done
  done

  return 1
}

validate_jetbrains_nerd_font() {
  if jetbrains_nerd_font_available; then
    echo "✓ font files available"
    return 0
  fi

  echo "⊘ warning: JetBrains Mono Nerd Font files were not found in ~/Library/Fonts or /Library/Fonts"
  echo "  Fully restart Alacritty after the font install finishes. If the warning persists, re-run this script."
  return 1
}

install_nerd_font() {
  section "Nerd Font (JetBrains Mono)"

  local cask="font-jetbrains-mono-nerd-font"

  if brew list --cask "$cask" >/dev/null 2>&1; then
    if jetbrains_nerd_font_available; then
      echo "✓ already installed and available"
      return
    fi

    echo "⊘ cask installed, but font files are missing"
    echo "→ reinstalling..."
    brew reinstall --cask "$cask"
    validate_jetbrains_nerd_font || true
    return
  fi

  echo "→ installing..."
  brew install --cask "$cask"
  validate_jetbrains_nerd_font || true
}

install_prettier() {
  section "Prettier"
  if command -v prettier >/dev/null 2>&1; then
    echo "✓ already installed"
    return
  fi
  echo "→ installing..."
  npm install -g prettier
  echo "✓ installed"
}

install_dotnet_tools() {
  section ".NET SDK + tools"

  if ! command -v dotnet >/dev/null 2>&1; then
    if brew list --cask dotnet-sdk >/dev/null 2>&1; then
      echo "⊘ dotnet-sdk cask installed but not on PATH; restart your shell first"
    else
      echo "→ installing dotnet-sdk..."
      brew install --cask dotnet-sdk
      echo "✓ dotnet-sdk installed"
    fi
  else
    echo "✓ dotnet already available"
  fi

  export PATH="$HOME/.dotnet/tools:$PATH"

  for tool in csharpier roslyn-language-server; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "✓ $tool already installed"
    else
      echo "→ installing $tool..."
      dotnet tool install -g "$tool" || echo "⊘ $tool install failed (may need a new shell after dotnet-sdk)"
    fi
  done
}

print_summary() {
  section "Post-install notes"
  cat <<'EOF'
  1. If you just installed rustup-init, run:
       rustup-init -y
     then restart your shell.

  2. If you just installed dotnet-sdk, restart your shell so
     ~/.dotnet/tools is on PATH, then re-run this script to
     finish installing csharpier and roslyn-language-server.

  3. Set JetBrains Mono Nerd Font as your terminal font
     (Alacritty config should already reference it).
EOF
}

install_xcode_clt
install_homebrew
install_brew_packages
install_nerd_font
install_prettier
install_dotnet_tools
print_summary
