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

# Append dir to PATH (skip if absent or already present)
path_append() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$PATH:$dir" ;;
  esac
}

path_prepend "$HOME/.local/bin"          # user-local binaries
path_prepend "$HOME/.dotnet/tools"        # dotnet global tools
eval "$(/opt/homebrew/bin/brew shellenv)" # initialize Homebrew
path_append "/usr/local/share/dotnet"     # dotnet (Intel fallback path)
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec" # .NET SDK root
fpath+=("/opt/homebrew/share/zsh/site-functions")     # Homebrew zsh completions

# Detect Java home via macOS system utility
if [[ -x /usr/libexec/java_home ]]; then
  macos_java_home="$(/usr/libexec/java_home 2>/dev/null || true)"
  [[ -n "$macos_java_home" ]] && export JAVA_HOME="$macos_java_home"
fi

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
unset macos_java_home
unfunction path_prepend path_append
