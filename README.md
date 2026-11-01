# WSL Development Dotfiles

Portable Neovim and tmux configuration for Ubuntu on WSL2, built around LazyVim, Tokyo Night Moon, and a keyboard-first tmux workflow. This repo contains personal configuration and setup documentation; plugin code and toolchains are installed separately by their own projects.

## Install on a new WSL machine

```bash
sudo apt update
sudo apt install -y git curl unzip build-essential python3 python3-venv python3-pip tmux fzf ripgrep fd-find
mkdir -p ~/projects
cd ~
git clone https://github.com/konishdutta/dotfiles.git
cd dotfiles
./install.sh
./nvim/scripts/bootstrap.sh
```

The installer makes timestamped backups of any existing Neovim/tmux configuration before linking files. It does not remove those backups, move repositories, change shell startup files, or install predefined tmux layouts. Start tmux and press `Ctrl+A`, then `I` to install TPM plugins. Start Neovim; Lazy.nvim restores the pinned plugins from `nvim/lazy-lock.json`.

The configuration and repositories belong in WSL's Linux filesystem (for example `~/dotfiles` and `~/projects`), not under `/mnt/c`. The `nvim/scripts/bootstrap.sh` script installs the pinned Neovim release and user-local language tooling. Review it before use on a new machine. Some optional language servers are installed with `:Mason` when first used.

## What's included

- `nvim/` — LazyVim starter configuration, lockfile, Python debugging sample, smoke tests, cheatsheet, and verification notes.
- `tmux/` — tmux 3.x configuration, Tokyo Night Moon/TPM plugin declarations, persistence test, README, and cheatsheet.
- `tmux-sessionizer/` — project search roots for the fzf session picker.
- `scripts/install-sessionizer.sh` — downloads ThePrimeagen's official sessionizer at a pinned commit, verifies its SHA-256, then applies two local changes: collision-resistant project session names and no `.tmux-sessionizer` command sourcing. The upstream repository currently has no license file, so its script is fetched at install time instead of copied into this repo.
- `install.sh` — backup-first symlinks and TPM bootstrap.

Neovim and tmux plugin versions are recorded in `nvim/lazy-lock.json` and managed by TPM respectively. The tmux themes/plugins remain independent upstream projects; update them with TPM (`Ctrl+A`, `U`) and inspect changes before adopting them.

## Update and repair

```bash
cd ~/dotfiles && git pull --ff-only
nvim/scripts/bootstrap.sh                 # refreshes the pinned/base toolchain
# inside tmux: Ctrl+A then I (install new plugins), or U (update plugins)
# inside nvim: :Lazy sync (restore pins), :Lazy update (advance pins)
```

After updating Neovim plugins, review and commit any intentional `nvim/lazy-lock.json` changes. To restore a previous plugin state, check out the corresponding lockfile revision and run `:Lazy sync`. Re-run `nvim/scripts/smoke-test.sh` and `tmux/tests/verify-isolated.sh` after changes.

## Windows Terminal

Install JetBrainsMono Nerd Font on Windows, then choose it in Windows Terminal: **Settings → Ubuntu profile → Appearance → Font face**. Restart the terminal tab. For clipboard copy, make sure `win32yank.exe` is available in the WSL interop PATH. On a fresh machine, install Neovim for Windows or another compatible `win32yank.exe` provider; the tmux config calls it by command name rather than embedding this machine's Windows path.

## Safety and private data

Do not commit tmux-resurrect snapshots, shell history, API keys, local environment files, virtual environments, caches, or timestamped backups. Session snapshots may contain working-directory paths and terminal text; they stay in each machine's home directory and are not part of this repo. Codex CLI authentication is likewise local and is not included.
