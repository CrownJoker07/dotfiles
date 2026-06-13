# ===============================
# Basic
# ===============================
export EDITOR=nvim
export VISUAL=nvim

# 历史记录
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history

# 输入体验
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
# Optional zsh plugins from pacman
# ===============================
if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

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
# 放在最后，避免被其他 prompt 覆盖
# ===============================
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
