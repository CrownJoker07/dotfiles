# ===============================
# macOS environment
# ===============================
# Prepend dir to PATH (skip if absent or already present)
path_prepend() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

path_prepend "$HOME/.local/bin"          # user-local binaries
eval "$(/opt/homebrew/bin/brew shellenv)" # initialize Homebrew
fpath+=("/opt/homebrew/share/zsh/site-functions")     # Homebrew zsh completions

# Source user-defined local environment script
if [[ -r "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

# ===============================
# Base zsh config
# ===============================
# Resolve this file's real path (follow symlinks) and source shared base config
current_zshrc="${(%):-%N}"
if [[ -L "$current_zshrc" ]]; then
  current_zshrc="$(readlink "$current_zshrc")"
fi

if [[ -r "${current_zshrc:h:h}/base/.zshrc" ]]; then
  source "${current_zshrc:h:h}/base/.zshrc"
fi

# Clean up temporary variables and helper functions
unset current_zshrc
unfunction path_prepend
