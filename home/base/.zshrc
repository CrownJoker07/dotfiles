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
# 将补全系统的初始化函数 compinit 标记为自动加载：首次调用时才从 $fpath 查找并载入函数定义。
# -U 阻止当前别名在函数载入时被展开，避免用户别名意外改变函数内容；-z 使用 zsh 原生的自动加载方式。
autoload -Uz compinit
# 初始化 zsh 补全系统：扫描 $fpath 中的补全定义、注册各命令的补全规则，并生成或复用 ~/.zcompdump 缓存以加快后续启动。
# 初始化后，在交互式命令行输入命令、选项、路径或子命令并按 Tab，即可显示和选择匹配的补全候选项。
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
alias vim='nvim'
alias vi='nvim'
alias grep='grep --color=auto'

# ===============================
# mise (dev tools version manager)
# ===============================
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

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

# ===============================
# Auto start tmux (local sessions only)
# ===============================
if [[ -z "$TMUX" && -n "$PS1" && -z "$SSH_CONNECTION" && "$TERM_PROGRAM" == "WezTerm" ]]; then
  tmux new -A -s main
fi

# ===============================
# Secrets (API keys, tokens)
# Load from ~/.secrets/ if exists
# ===============================
if [[ -d "$HOME/.secrets" ]]; then
  for secret_file in "$HOME/.secrets"/*(N); do
    [[ -f "$secret_file" ]] && source "$secret_file"
  done
fi
