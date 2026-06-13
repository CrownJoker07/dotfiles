# ===============================
# Basic
# ===============================
export EDITOR=nvim
export VISUAL=nvim

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history

# Input
setopt autocd
setopt no_beep
bindkey -e

# ===============================
# Completion
# ===============================
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ===============================
# Optional zsh plugins
# Support: Arch Linux, macOS (Homebrew)
# ===============================
for plugin_dir in \
  /usr/share/zsh/plugins \
  /opt/homebrew/share \
  /usr/local/share; do
  if [[ -r "$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi
  if [[ -r "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
done

# ===============================
# Useful aliases
# ===============================
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -al --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

alias vim='nvim'
alias vi='nvim'
alias grep='grep --color=auto'

# ===============================
# zoxide
# ===============================
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ===============================
# Starship prompt
# Must be placed near the end
# ===============================
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
