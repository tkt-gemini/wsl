<div align="center">

# WSL Ubuntu 26.04

**Workflow for Embodied AI**

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

### Step 1 — APT: System Layer

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y $(cat apt-pkgs.txt | grep -v '^#' | tr '\n' ' ')
```

Key packages in [`apt-pkgs.txt`](apt-pkgs.txt): `build-essential`, `curl`, `git`,
`libssl-dev`, `zsh`, and other system libraries.

#### Set Zsh as default shell

```bash
chsh -s $(which zsh)
# Log out and back in for the change to take effect
```

→ Zsh config: [`.zshrc`](.zshrc)

#### Git configuration

```bash
git config --global user.name  "<name>"
git config --global user.email "<email>"
git config --global core.editor "nvim"

# SSH key for GitHub
ssh-keygen -t ed25519 -C "<email>"
cat ~/.ssh/id_ed25519.pub   # paste this into GitHub → Settings → SSH keys
```

---

### Step 2 — mise: Tooling Layer

[mise](https://mise.jdx.dev) manages dev runtimes (Node, Python, Go…) and CLI tools as versioned, shim-based installs — no `sudo` needed.

```bash
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

Install runtimes and tools from the shared config:

```bash
# Config lives at: https://github.com/tkt-gemini/mise
mise install

# Verify
mise list
```

---

### Step 3 — Zsh plugins: Zinit

[Zinit](https://github.com/zdharma-continuum/zinit) is a fast Zsh plugin manager with lazy-loading support.

```bash
bash -c "$(curl --fail --show-error --silent --location \
  https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

---

### Step 4 — Prompt: Starship

```bash
curl -sS https://starship.rs/install.sh | sh
```

---

### Step 5 — pixi: AI/ML Layer

[pixi](https://pixi.sh) creates conda-based, per-project environments. Ideal for locking CUDA versions alongside Python packages.

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

**Typical project workflow:**

```bash
cd my-robot-project
pixi init
pixi add python=3.11 pytorch torchvision pytorch-cuda=12.1 -c pytorch -c nvidia
pixi shell   # activate the environment
```

---

### Step 6 — Multiplexer: Zellij

```bash
mise use -g github:zellij-org/zellij

# Verify
zellij --version
```

→ Layout & keybind config: [tkt-gemini/zellij](https://github.com/tkt-gemini/zellij)

---

### Step 7 — Editor: Neovim

```bash
mise use -g github:neovim/neovim

# Verify
nvim --version
```

→ Full config (lazy.nvim, LSP, etc.): [tkt-gemini/neovim](https://github.com/tkt-gemini/neovim)

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
