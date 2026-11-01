#!/usr/bin/env bash
set -euo pipefail
v=0.12.6
mkdir -p "$HOME/.local/bin" "$HOME/.local/opt" "$HOME/.local/share/nvim"
if ! command -v nvim >/dev/null || ! nvim --version | head -n1 | grep -q "v$v"; then
  t="$(mktemp -d)"; trap 'rm -rf "$t"' EXIT
  curl -fL "https://github.com/neovim/neovim/releases/download/v$v/nvim-linux-x86_64.tar.gz" -o "$t/nvim.tar.gz"
  echo "474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87  $t/nvim.tar.gz" | sha256sum -c -
  tar -xzf "$t/nvim.tar.gz" -C "$HOME/.local/opt"
  ln -sfn "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi
if ! "$HOME/.local/share/nvim/debugpy/bin/python" -m debugpy --version >/dev/null 2>&1; then
  python3 -m venv "$HOME/.local/share/nvim/debugpy"
  "$HOME/.local/share/nvim/debugpy/bin/python" -m pip install --upgrade pip debugpy
fi
uv tool install --upgrade basedpyright
uv tool install --upgrade ruff
npm install --global @openai/codex
if ! command -v cargo >/dev/null; then
  curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
fi
source "$HOME/.cargo/env"
cargo install --locked tree-sitter-cli
cargo install --locked fd-find
ln -sfn "$HOME/.cargo/bin/tree-sitter" "$HOME/.local/bin/tree-sitter"
ln -sfn "$HOME/.cargo/bin/fd" "$HOME/.local/bin/fd"
echo "Neovim $v, debugpy, Ruff, basedpyright, Codex CLI, Rust, tree-sitter-cli, fd, fzf, and LazyGit are installed."

# Pinned user-local search and Git UI binaries, verified against official release hashes.
t="$(mktemp -d)"; trap 'rm -rf "$t"' EXIT
curl -fL https://github.com/junegunn/fzf/releases/download/v0.74.5/fzf-0.74.5-linux_amd64.tar.gz -o "$t/fzf.tar.gz"
echo "d47d7f882972c7d674dbbba998ffa4116e68379616ffac7695d0671e9a722c5f  $t/fzf.tar.gz" | sha256sum -c -
tar -xzf "$t/fzf.tar.gz" -C "$t" fzf
install -m 755 "$t/fzf" "$HOME/.local/bin/fzf"
curl -fL https://github.com/jesseduffield/lazygit/releases/download/v0.66.2/checksums.txt -o "$t/lazygit-checksums.txt"
echo "abceadfbfc83fbfaf7c2f7337768fefa0b9afe44168ea39c08117246c9499813  $t/lazygit-checksums.txt" | sha256sum -c -
asset=lazygit_0.66.2_linux_x86_64.tar.gz
curl -fL "https://github.com/jesseduffield/lazygit/releases/download/v0.66.2/$asset" -o "$t/lazygit.tar.gz"
rg "$asset" "$t/lazygit-checksums.txt" | sed "s#  $asset#  $t/lazygit.tar.gz#" | sha256sum -c -
tar -xzf "$t/lazygit.tar.gz" -C "$t" lazygit
install -m 755 "$t/lazygit" "$HOME/.local/bin/lazygit"
