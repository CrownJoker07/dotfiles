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
  local packages=(neovim git tmux alacritty fzf ripgrep lazygit stylua shfmt node rustup-init)
  echo "→ ${packages[*]}"
  brew install "${packages[@]}"
  echo "✓ installed"
}

install_nerd_font() {
  section "Nerd Font (JetBrains Mono)"
  if brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
    echo "✓ already installed"
    return
  fi
  echo "→ installing..."
  brew install --cask font-jetbrains-mono-nerd-font
  echo "✓ installed"
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
