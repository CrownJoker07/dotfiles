# ===============================
# macOS environment
# ===============================
path_prepend() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

path_append() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$PATH:$dir" ;;
  esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.dotnet/tools"
path_prepend "/opt/homebrew/bin"
path_append "/usr/local/share/dotnet"

if [[ -x /usr/libexec/java_home ]]; then
  macos_java_home="$(/usr/libexec/java_home 2>/dev/null || true)"
  [[ -n "$macos_java_home" ]] && export JAVA_HOME="$macos_java_home"
fi

if [[ -r "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

# ===============================
# Base zsh config
# ===============================
current_zshrc="${(%):-%N}"
if [[ -L "$current_zshrc" ]]; then
  current_zshrc="$(readlink "$current_zshrc")"
fi

if [[ -r "${current_zshrc:h:h}/base/.zshrc" ]]; then
  source "${current_zshrc:h:h}/base/.zshrc"
fi

unset current_zshrc
unset macos_java_home
unfunction path_prepend path_append
