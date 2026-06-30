# Agent Guide

This repository is a cross-platform dotfiles setup for macOS and Arch Linux.
Keep the two systems as close as practical while respecting platform-specific
package names, paths, and desktop behavior.

## Repository Layout

- `config/base/`: XDG config shared by macOS and Linux.
- `home/base/`: home-directory dotfiles shared by macOS and Linux.
- `config/macos/` and `home/macos/`: macOS-only overrides.
- `config/linux/` and `home/linux/`: Linux-only overrides.
- `packages/packages.conf`: package manifest for macOS Homebrew formulae/casks
  and Arch pacman, archlinuxcn, and AUR packages.
- `scripts/`: installer and symlink logic.

## Cross-Platform Rules

- Prefer changing `base` files first. Add platform-specific files only when the
  behavior truly differs between macOS and Linux.
- Preserve the installer flow: `install.sh` symlinks config first, then runs the
  platform package installer unless `-d` is used.
- Keep package lists aligned by capability, not necessarily by exact package
  name. For example, Homebrew cask `codex` corresponds to Arch `openai-codex`.
- Do not add unrelated refactors or style churn while changing dotfiles.

## Package Management Rules

- Do not add repository scripts that build system software from source.
- Do not use `makepkg`, `cargo install`, `go install`, `pip install`, or manual
  `git clone` build flows for system dependencies.
- Prefer package-managed binary installs: Homebrew on macOS, official `pacman`
  repositories on Arch, and the configured `archlinuxcn` binary repository for
  packages that are not in official Arch repositories.
- Keep `packages/packages.conf` as the source of truth for ordinary packages. Do not
  add package-specific install, reinstall, or filesystem validation functions
  to installer scripts when the package can be listed under `packages/`.
  Bootstrap steps such as Xcode Command Line Tools, Homebrew installation, and
  Arch repository/keyring setup are acceptable exceptions.
- AUR packages are allowed only through an already installed AUR helper such as
  `paru` or `yay`. This repository must not build the helper itself; install
  `yay` through `archlinuxcn` when possible.
- Do not add Flatpak support to the Linux installer. Prefer `pacman`,
  `archlinuxcn`, then AUR helper packages.
- Before adding a package under `arch.aur` in `packages/packages.conf`, verify it
  is not already available in the official `pacman` or `archlinuxcn`
  repositories. Use the package-managed equivalent when available.
- Homebrew formula installs should use bottles and avoid source fallback.
- Neovim plugins and plugin-side Lua package metadata are managed by
  `lazy.nvim`. Keep lazy package sources enabled, including `rockspec`/rocks,
  unless a concrete plugin compatibility issue requires a local override.
- Neovim editor tools are managed by Mason. Do not duplicate Mason-managed LSP
  servers, formatters, or parser tooling in system package lists unless there
  is a clear reason. This includes `tree-sitter-cli`, `shfmt`, and `stylua`.
- Language runtimes and per-user developer toolchains are managed by `mise`.
  Do not add `node`, `python`, `dotnet`, or similar runtime packages to system
  package lists unless another system-managed package requires them or desktop
  integration depends on them.
- tmux plugins are managed by TPM. The TPM executable itself should come from a
  package manager when possible.

## Validation

Run these checks after modifying installer scripts or package lists:

```sh
bash -n install.sh scripts/install-arch.sh scripts/install-macos.sh scripts/symlink.sh
awk 'NF && $0 !~ /^#/ && $0 !~ /^\[[^]]+\]( # .*)?$/ && $0 !~ /^[a-z]+\.[a-z]+ = / { print FNR ": " $0; bad=1 } END { exit bad }' packages/packages.conf
! rg -n "makepkg|git clone https://aur.archlinux.org|base-devel|build-from-source|cargo install|go install|pip install|flatpak" scripts packages
./install.sh -d
```

The dry run should only report symlink actions and must not install packages.
