#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
backup_and_link() {
  local source="$1" destination="$2" parent backup
  mkdir -p "$(dirname "$destination")"
  if [[ -L "$destination" && "$(readlink -f "$destination" || true)" == "$(readlink -f "$source")" ]]; then
    printf 'Already linked: %s\n' "$destination"
    return
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    parent="$(dirname "$destination")"
    backup="$parent/$(basename "$destination").backup-$STAMP"
    while [[ -e "$backup" || -L "$backup" ]]; do backup="$backup-$(date +%s%N)"; done
    mv -- "$destination" "$backup"
    printf 'Backed up existing path: %s\n' "$backup"
  fi
  ln -s -- "$source" "$destination"
  printf 'Linked: %s -> %s\n' "$destination" "$source"
}

backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
backup_and_link "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"
backup_and_link "$DOTFILES_DIR/tmux-sessionizer/tmux-sessionizer.conf" "$HOME/.config/tmux-sessionizer/tmux-sessionizer.conf"
backup_and_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.tmux/plugins"
if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
mkdir -p "$HOME/.config/tmux"
if [[ ! -e "$HOME/.config/tmux/plugins" ]]; then
  ln -s "$HOME/.tmux/plugins" "$HOME/.config/tmux/plugins"
fi
"$DOTFILES_DIR/scripts/install-sessionizer.sh"
backup_and_link "$DOTFILES_DIR/scripts/tmux-git-ascii" "$HOME/.local/bin/tmux-git-ascii"

cat <<'MSG'
Configuration files are linked and existing paths were backed up before linking.
Install/update tmux plugins from inside tmux with Ctrl+A, then I.
Run nvim/scripts/bootstrap.sh to install the documented user-local development tools.
MSG
