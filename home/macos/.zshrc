# ===============================
# macOS environment
# ===============================
eval "$(/opt/homebrew/bin/brew shellenv)" # initialize Homebrew

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
