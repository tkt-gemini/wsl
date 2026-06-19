<div align="center">

# WSL Ubuntu 26.04

**Workflow for Embodied AI**

[![Python](https://img.shields.io/badge/Python-3.12%2B-blue)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-1.5.0-orange)](https://scikit-learn.org/)
[![License](https://img.shields.io/badge/LICENSE-MIT?style=for-the-badge&color=6B7F4E)](LICENSE)

</div>

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Windows 11 | WSL2 support required |
| WSL-2 | `wsl --set-default-version 2` |
| NVIDIA Driver ≥ 525 | For CUDA passthrough into WSL |
| Docker Desktop | Enable WSL integration in settings |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Windows Host                                           │
│  NVIDIA Driver (CUDA passthrough)  ·  Docker Desktop    │
└─────────────────────────┬───────────────────────────────┘
                          │ WSL2
┌─────────────────────────▼───────────────────────────────┐
│  1. APT — system layer                                  │
│     Build tools · system libs · git · curl              │
├─────────────────────────────────────────────────────────┤
│  2. mise — tooling layer                                │
│     Dev runtimes · ripgrep · bat · fzf · zellij · nvim  │
├─────────────────────────────────────────────────────────┤
│  3. pixi — AI/ML layer (per-project)                    │
│     PyTorch · transformers · CUDA runtime               │
├─────────────────────────────────────────────────────────┤
│  Shell: Zsh + Zinit + Starship                          │
│  Multiplexer: Zellij                                    │
│  Editor: Neovim                                         │
└─────────────────────────────────────────────────────────┘
```

> **Tooling philosophy:**
> - `apt` for system-level packages that don't change often
> - `mise` for portable runtimes and CLI tools across projects
> - `pixi` for reproducible, per-project AI/ML environments with CUDA

---

## Setup

> Follow the steps **in order** — each layer depends on the one above it.

### Step 1 — APT

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y $(cat apt-pkgs.txt | grep -v '^#' | tr '\n' ' ')
```

Packages in [`apt-pkgs.txt`](apt-pkgs.txt)

#### Git configuration

```bash
git config --global user.name  "<name>"
git config --global user.email "<email>"
git config --global core.editor "nvim"
# SSH key for GitHub
ssh-keygen -t ed25519 -C "<email>"
cat ~/.ssh/id_ed25519.pub # copy to SSH Github setting
```

---

### Step 2 — mise

[mise](https://mise.jdx.dev) manages dev runtimes and CLI tools as versioned.

```bash
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

Install runtimes and tools from the shared config:

```bash
mise install
mise list
```

Configuration for mise is [here](./mise-en-place/config.toml)

---

### Step 3 — Zsh

#### Set Zsh as default shell

```bash
chsh -s $(which zsh)
```

#### Zinit

[Zinit](https://github.com/zdharma-continuum/zinit) is a fast Zsh plugin manager with lazy-loading support.

```bash
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

---

#### Starship

```bash
curl -sS https://starship.rs/install.sh | sh
```

Configuration for zsh is [here](./zsh/.zshrc)

---

### Step 4 — pixi

[pixi](https://pixi.sh) creates conda-based, per-project environments. Ideal for locking CUDA versions alongside Python packages.

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

---

### Step 5 — Zellij

```bash
mise use -g github:zellij-org/zellij
zellij --version
```

Configuration [here](./zellij/config.kdl)

---

### Step 6 — Neovim

```bash
mise use -g github:neovim/neovim
nvim --version
```

Configuration [here](https://github.com/tkt-gemini/neovim)

---

## Toolchain Summary

| Tool | Role | Managed by |
|---|---|---|
| `apt` | System libs, build tools | system |
| `mise` | Runtimes, CLI tools | `~/.local/share/mise` |
| `pixi` | Per-project AI/ML envs | project `pixi.toml` |
| `zsh` + `zinit` | Shell + plugins | `~/.zshrc` |
| `starship` | Prompt | `~/.config/starship.toml` |
| `zellij` | Terminal multiplexer | mise (global) |
| `neovim` | Editor | mise (global) |
