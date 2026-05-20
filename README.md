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

sudo apt install -y \
  # Build tools
  build-essential \
  cmake \
  pkg-config \
  ninja-build \
  # Libraries
  libssl-dev \
  libffi-dev \
  libsqlite3-dev \
  libbz2-dev \
  libreadline-dev \
  libncurses5-dev \
  zlib1g-dev \
  liblzma-dev \
  libxml2-dev \
  # Utilities
  curl \
  wget \
  git \
  unzip \
  zip \
  xclip \
  xsel \
  fontconfig \
  ca-certificates \
  # Zsh
  zsh
```

### Set ZSH as the default shell

```bash
chsh -s $(which zsh)
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
mise use -g node@22        # LTS for web dev
mise use -g go@1.22        # For go tools

# CLI tools — Rust-based
mise use -g cargo:ripgrep    # rg replace grep
mise use -g cargo:bat        # bat replace cat
mise use -g cargo:fd-find    # fd  replace find
mise use -g cargo:eza        # eza replace ls
mise use -g cargo:git-delta  # git-delta replace git-diff
mise use -g cargo:zoxide     # z replace cd

# CLI tools — Go-based
mise use -g ubi:junegunn/fzf # fzf — fuzzy finder

# Verify
mise list
```

> **Note:** The first installation of `cargo:*` will compile from source code — please, wait 5–15 minutes. Subsequent installations will use cache.

---

## Zellij

```bash
mise use -g ubi:zellij-org/zellij
```

Create a basic configuration:

```bash
mkdir -p ~/.config/zellij
zellij setup --dump-config > ~/.config/zellij/config.kdl
```

```kdl
// Turn off welcome screen
simplified_ui true

// Theme
theme "tokyo-night"

// Turn off mouse mode if want copy text easily
mouse_mode false
```

---

## Neovim

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz

# Verify
nvim --version
```
---

## Pixi

### Install pixi

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

### Check CUDA on WSL

```bash
# Windows must have NVIDIA Driver >= 530
# WSL2 exposes GPU — no manual CUDA toolkit installation required

nvidia-smi
```

---

## ZSH config

```zsh
# ~/.zshrc

# --- Zinit ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit Annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Plugins — turbo mode (zi"!" = load now, zi = lazy)
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull"zinit creinstall -q ." \
    zsh-users/zsh-completions \
    jeffreytse/zsh-vi-mode

zinit wait lucid light-mode for \
  Aloxaf/fzf-tab

# --- Options ---
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# --- Environment Managers ---
# mise
eval "$(~/.local/bin/mise activate zsh)"

# fnm
eval "$(fnm env --use-on-cd)"

# --- zoxide (z command) ---
eval "$(zoxide init zsh)"

# --- fzf ---
eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
'

# --- pixi ---
export PATH="$HOME/.pixi/bin:$PATH"

# --- bat ---
export BAT_THEME="Catppuccin Mocha"

# --- delta (git diff) ---
export GIT_PAGER="delta"

# --- Aliases ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias vim='nvim'
alias vi='nvim'
alias zj='zellij'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# --- Zellij autostart ---
# Auto open Zellij when open a new terminal
# if [[ -z "$ZELLIJ" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
#   exec zellij
# fi

# --- Starship ---
eval "$(starship init zsh)"
```

---

## Verification Checklist

```bash
# System
gcc --version           # build-essential
git --version

# Shell
echo $SHELL             # /usr/bin/zsh

# mise + tools
mise --version
node -v
rg --version
bat --version
fd --version
eza --version
fzf --version
delta --version
z --version             # zoxide

# Zellij
zellij --version

# Neovim
nvim --version

# pixi
pixi --version

# GPU (if NVIDIA is available)
nvidia-smi
```
