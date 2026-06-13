#!/usr/bin/env bash
# Arch Linux setup - installs packages via pacman and yay

set -euo pipefail

if [ "$(uname -s)" != "Linux" ]; then
  echo "⊘ skip: not Linux"
  exit 0
fi

if [ ! -f /etc/arch-release ]; then
  echo "⊘ skip: not Arch Linux"
  exit 0
fi

section() { echo; echo "━━━ $1 ━━━"; }

install_base_deps() {
  section "基础依赖 (git, base-devel)"
  sudo pacman -S --needed --noconfirm git base-devel
  echo "✓ 基础依赖已就绪"
}

install_yay() {
  section "yay (AUR helper)"
  if command -v yay >/dev/null 2>&1; then
    echo "✓ already installed: $(yay --version | head -1)"
    return
  fi

  echo "→ building from AUR..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
  )
  rm -rf "$tmpdir"

  if command -v yay >/dev/null 2>&1; then
    echo "✓ yay installed"
  else
    echo "✗ yay install failed"
    exit 1
  fi
}

install_pacman_packages() {
  section "pacman 包"

  local packages=(
    neovim
    git
    tmux
    fzf
    ripgrep
    shfmt
    nodejs
    rustup
    tree-sitter
    dotnet-sdk
    konsole
    zsh
    starship
    eza
    bat
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
  )

  local missing=()
  local pkg

  for pkg in "${packages[@]}"; do
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg already installed"
    else
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi

  echo "✓ pacman 包已就绪"
}

install_aur_packages() {
  section "AUR 包 (yay)"

  local packages=(
    lazygit
    stylua
    ttf-jetbrains-mono-nerd
  )

  local missing=()
  local pkg

  for pkg in "${packages[@]}"; do
    if yay -Qi "$pkg" >/dev/null 2>&1; then
      echo "✓ $pkg already installed"
    else
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "→ installing: ${missing[*]}"
    yay -S --needed --noconfirm "${missing[@]}"
  fi

  echo "✓ AUR 包已就绪"
}

install_prettier() {
  section "Prettier"
  if command -v prettier >/dev/null 2>&1; then
    echo "✓ already installed"
    return
  fi

  if ! command -v npm >/dev/null 2>&1; then
    echo "⊘ skip: npm not available"
    return
  fi

  echo "→ installing..."
  npm install -g prettier
  echo "✓ installed"
}

install_dotnet_tools() {
  section ".NET 工具"

  export PATH="$HOME/.dotnet/tools:$PATH"

  if ! command -v dotnet >/dev/null 2>&1; then
    echo "⊘ skip: dotnet not available (restart shell if just installed)"
    return
  fi

  if command -v csharpier >/dev/null 2>&1; then
    echo "✓ csharpier already installed"
    return
  fi

  echo "→ installing csharpier..."
  dotnet tool install -g csharpier
  echo "✓ csharpier installed"
}

configure_zsh() {
  section "默认 Shell"

  if [ "$(basename "$SHELL")" = "zsh" ]; then
    echo "✓ 默认 Shell 已是 zsh"
    return
  fi

  echo "→ 切换默认 Shell 为 zsh..."
  chsh -s /usr/bin/zsh
  echo "✓ 已切换 (注销重新登录后生效)"
}

print_summary() {
  section "安装后提示"
  cat <<'EOF'
  1. 注销并重新登录，使以下变更生效：
       - 默认 Shell 切换为 zsh
       - ~/.zshrc 生效

  2. 打开 Konsole，确认：
       - 字体：JetBrainsMono Nerd Font
       - 配色：catppuccin-mocha
       - 或直接使用 "JetBrains" Profile

  3. 如果刚安装了 rustup，请运行：
       rustup-init -y
     然后重启 shell。

  4. 如果刚安装了 dotnet-sdk，请重启 shell 使
     ~/.dotnet/tools 加入 PATH，然后重新运行此脚本
     以安装 csharpier。
EOF
}

install_base_deps
install_yay
install_pacman_packages
install_aur_packages
install_prettier
install_dotnet_tools
configure_zsh
print_summary
