# Dotfiles

面向 macOS、Arch Linux 和 Windows 的个人开发环境配置。三个平台尽量共享同一套配置，并通过各自的包管理器安装对应软件。

## 获取仓库

```sh
git clone https://github.com/CrownJoker07/dotfiles.git
cd dotfiles
```

## macOS

先执行 dry run，确认将要创建的链接：

```sh
./install.sh -d
```

确认后执行安装：

```sh
./install.sh
```

安装程序会依次：

1. 将共享配置和 macOS 专属配置链接到用户目录。
2. 检查并安装 Xcode Command Line Tools 和 Homebrew。
3. 使用 Homebrew 安装 `packages/packages.conf` 中的 macOS 软件。
4. 安装 tmux 插件和 mise 管理的开发工具。

## Arch Linux

先执行 dry run：

```sh
./install.sh -d
```

确认后执行安装：

```sh
./install.sh
```

安装程序会依次：

1. 将共享配置和 Linux 专属配置链接到用户目录。
2. 配置 `archlinuxcn` 软件仓库。
3. 使用 `pacman`、`archlinuxcn` 和已安装的 AUR helper 安装对应软件。
4. 安装 tmux 插件和 mise 管理的开发工具。
5. 将默认 shell 切换为 zsh。

安装系统软件和修改默认 shell 时可能要求输入 `sudo` 密码。

## Windows

Windows 安装入口是 PowerShell 脚本。系统需要提供 `winget`；创建符号链接还需要启用 Windows“开发人员模式”，或者使用管理员 PowerShell。

先执行 dry run：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
```

确认后执行安装：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

安装程序会依次：

1. 将共享配置链接到 `$HOME\.config` 和用户主目录。
2. 应用 `config/windows` 和 `home/windows` 中存在的 Windows 专属覆盖。
3. 使用 `winget` 安装 `packages/packages.conf` 中的 Windows 软件。

如果当前终端使用 PowerShell 7，也可以将命令中的 `powershell` 换成 `pwsh`。

## 安装参数

macOS 和 Arch Linux：

```text
-d    只显示将要进行的操作，不创建链接或安装软件
-f    备份已存在的目标文件，然后创建链接
-h    显示帮助
```

Windows：

```text
-DryRun, -d    只显示将要进行的链接操作，并跳过软件安装
-Force,  -f    备份已存在的目标文件，然后创建链接
```

备份文件会保留在原文件旁边，名称格式为：

```text
原文件名.bak.YYYYMMDD_HHMMSS
```

## 配置结构

```text
config/base/       三个平台共享的 XDG 配置
config/macos/      macOS 专属配置
config/linux/      Linux 专属配置
config/windows/    Windows 专属配置
home/base/         三个平台共享的主目录配置
home/macos/        macOS 专属主目录配置
home/linux/        Linux 专属主目录配置
home/windows/      Windows 专属主目录配置
packages/          各平台的软件包清单
scripts/           软链接和平台安装脚本
```

平台专属文件会覆盖同路径的共享文件。当前不存在的平台目录会被自动跳过，不需要创建空目录。

## 软件包清单

`packages/packages.conf` 是普通系统软件的统一来源。每项功能可以分别声明各平台的软件包：

```text
macos.formula = ripgrep
arch.pacman = ripgrep
windows.winget = BurntSushi.ripgrep.MSVC
```

macOS 使用 Homebrew，Arch Linux 使用 `pacman`、`archlinuxcn` 或 AUR helper，Windows 使用 `winget`。语言运行时由 mise 管理，Neovim 编辑器工具由 Mason 管理。
