# WSL Ubuntu 26.04 — Setup environment for dev

> Stack: Zsh + Zinit + Starship + Zellij + Neovim + mise + pixi

---

## Overview

```
┌─────────────────────────────────────────────────────┐
│  Windows: NVIDIA Driver (cho CUDA passthrough)      │
└──────────────────────────┬──────────────────────────┘
                           │ WSL2
┌──────────────────────────▼──────────────────────────┐
│  APT — system layer                                 │
│  build tools, system libs, git, curl                │
├─────────────────────────────────────────────────────┤
│  mise — tooling layer                               │
│  Node, Python, CLI tools (ripgrep, bat, fzf...)     │
├─────────────────────────────────────────────────────┤
│  pixi — AI/ML layer (per-project)                   │
│  PyTorch, transformers, CUDA runtime...             │
├─────────────────────────────────────────────────────┤
│  Shell: Zsh + Zinit + Starship                      │
│  Terminal mux: Zellij                               │
│  Editor: Neovim                                     │
└─────────────────────────────────────────────────────┘
```

---

## APT: System Layer

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y build-essential cmake pkg-config ninja-build libssl-dev libffi-dev libsqlite3-dev libbz2-dev libreadline-dev libncurses5-dev zlib1g-dev liblzma-dev libxml2-dev curl wget git unzip zip xclip xsel fontconfig ca-certificates zsh
```

### Set ZSH as the default shell

```bash
chsh -s $(which zsh)
```

### Git Configuration

```bash
git config --global user.name "<name>"
git config --global user.email "<email>"
git config --global core.editor "nvim"
ssh-keygen -t ed25519 -C "<email>"
cat ~/.ssh/id_ed25519.pub
```

---

## Zinit

```bash
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

---

## Starship

```bash
curl -sS https://starship.rs/install.sh | sh
```

---

## Mise

### Install mise

```bash
curl https://mise.run | sh

echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### Install runtimes and CLI tools

```bash
# Runtimes
mise use -g node@24        # LTS for web dev
mise use -g go@1.22        # For go tools

# CLI tools — Rust-based (Pre-compiled)
mise use -g ripgrep    # rg replace grep
mise use -g bat        # bat replace cat
mise use -g fd         # fd  replace find
mise use -g eza        # eza replace ls
mise use -g zoxide     # z replace cd

# CLI tools — Go-based
mise use -g github:junegunn/fzf # fzf — fuzzy finder

# Verify
mise list
```

---

## Zellij

```bash
mise use -g github:zellij-org/zellij
```

Create a basic configuration:

```kdl
simplified_ui true
theme "tokyo-night"
mouse_mode false
```

---

## Neovim

```bash
mise use -g github:neovim/neovim
```
---

## Pixi

### Install pixi

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

---

## ZSH Configuration

```zsh
# Created by newuser for 5.9

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
    print -P "%F{33} %F{34}Installation successful.%f%b" || \
    print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
  zle -N zle-keymap-select ""
fi
eval "$(starship init zsh)"

eval "$(~/.local/bin/mise activate zsh)"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust \

zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull"zinit creinstall -q ." \
    zsh-users/zsh-completions \
  depth"1" \
    jeffreytse/zsh-vi-mode

### End of Zinit's installer chunk

export PATH="$HOME/.pixi/bin:$PATH"
```

---

## Verification Checklist

```bash
# System
gcc --version
git --version

# Shell
echo $SHELL

# mise + tools
mise --version
node -v
rg --version
bat --version
fd --version
eza --version
fzf --version
delta --version
zoxide --version

# Zellij
zellij --version

# Neovim
nvim --version

# pixi
pixi --version

# GPU (if NVIDIA is available)
nvidia-smi
```
