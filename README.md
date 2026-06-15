<div align="center">

# WSL Ubuntu 26.04

**Workflow for Embodied AI**

</div>

<details>
<summary>Workflow</summary>

- **Terminal emulator:** windows-terminal *(now)*; ghostty *(future)*
- **Shell:** zsh; zinit; starship
- **Package manager:** apt; mise; pixi
- **Multiplexer:** zellij
- **Editor:** neovim

</details>

---

## Overview

```
┌─────────────────────────────────────────────────────┐
│  Windows:                                           │
│  NVIDIA Driver (for CUDA passthrough)               │
│  Docker desktop (WSL intergration)                  │
└──────────────────────────┬──────────────────────────┘
                           │ WSL2
┌──────────────────────────▼──────────────────────────┐
│  APT — system layer                                 │
│  Build tools, system libs, git, curl                │
├─────────────────────────────────────────────────────┤
│  mise — tooling layer                               │
│  Dev runtimes, CLI tools (ripgrep, bat, fzf...)     │
├─────────────────────────────────────────────────────┤
│  pixi — AI/ML layer (per-project)                   │
│  PyTorch, transformers, CUDA runtime...             │
├─────────────────────────────────────────────────────┤
│  Shell: Zsh; Zinit; Starship                        │
│  Multiplexer: Zellij                                │
│  Editor: Neovim                                     │
└─────────────────────────────────────────────────────┘
```

---

## APT: System Layer

```bash
sudo apt update && sudo apt upgrade -y
# install all necessary packages for apt
sudo apt install -y $(cat apt-pkgs.txt | grep -v '^#' | tr '\n' ' ')
```

### Set ZSH as the default shell

```bash
chsh -s $(which zsh)
```

Details configuration [here](.zshrc)

### Git Configuration

```bash
git config --global user.name "<name>"
git config --global user.email "<email>"
git config --global core.editor "nvim"
ssh-keygen -t ed25519 -C "<email>"
cat ~/.ssh/id_ed25519.pub
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

Details configuration [here](https://github.com/tkt-gemini/mise)

```bash
# Verify
mise list
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

## Pixi

### Install pixi

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

---

## Zellij

```bash
mise use -g github:zellij-org/zellij
```

Details configuration [here](https://github.com/tkt-gemini/zellij)

---

## Neovim

```bash
mise use -g github:neovim/neovim
```

Details configuration [here](https://github.com/tkt-gemini/neovim)

---

