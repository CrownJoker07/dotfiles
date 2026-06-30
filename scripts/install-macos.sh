#!/usr/bin/env bash
# macOS setup - installs from packages/

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "⊘ skip: not macOS"
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

is_in_list() {
  local needle="$1"
  local haystack="$2"

  printf '%s\n' "$haystack" | grep -Fxq "$needle"
}

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

install_brew_formulae() {
  section "Homebrew formulae"

  local formula_list
  formula_list="$(read_package_list macos/brew-formulae.txt)" || return 0

  local installed_formulae
  installed_formulae="$(brew list --formula)"

  local formula
  local missing=()
  while IFS= read -r formula; do
    [ -z "$formula" ] && continue
    if is_in_list "$formula" "$installed_formulae"; then
      echo "✓ $formula"
    else
      missing+=("$formula")
    fi
  done <<< "$formula_list"

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing ${#missing[@]} formula(e) from bottles: ${missing[*]}"
    brew install --force-bottle "${missing[@]}"
  fi

  echo "✓ brew formulae ready"
}

install_brew_casks() {
  section "Homebrew casks"

  local cask_list
  cask_list="$(read_package_list macos/brew-casks.txt)" || return 0

  local installed_casks
  installed_casks="$(brew list --cask)"

  local cask
  local missing=()
  while IFS= read -r cask; do
    [ -z "$cask" ] && continue
    if is_in_list "$cask" "$installed_casks"; then
      echo "✓ $cask"
    else
      missing+=("$cask")
    fi
  done <<< "$cask_list"

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing ${#missing[@]} cask(s): ${missing[*]}"
    brew install --cask "${missing[@]}"
  fi

  echo "✓ brew casks ready"
}

install_tmux_plugins() {
  section "tmux plugins"

  local brew_prefix
  brew_prefix="$(brew --prefix)"
  local tpm_path="$brew_prefix/share/tpm"

  if [ ! -f "$tpm_path/tpm" ] && [ -f "$HOME/.tmux/plugins/tpm/tpm" ]; then
    tpm_path="$HOME/.tmux/plugins/tpm"
  fi

  if [ ! -f "$tpm_path/tpm" ]; then
    echo "✗ tpm not found (install tpm via Homebrew)"
    return 1
  fi

  echo "→ installing plugins via tpm ($tpm_path)..."
  local session_name="_tpm_install_$$"
  tmux start-server
  tmux new-session -d -s "$session_name" 2>/dev/null || true
  tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
  export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/"
  tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$TMUX_PLUGIN_MANAGER_PATH"
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
  section "Post-install notes"
  cat <<'EOF'
  1. Roslyn language server is managed by Neovim Mason.
     Open Neovim and run :MasonInstall roslyn-language-server if it is not
     installed automatically.
EOF
}

install_xcode_clt
install_homebrew
install_brew_formulae
install_brew_casks
install_tmux_plugins
install_mise_tools
print_summary
