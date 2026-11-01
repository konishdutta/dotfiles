# Quick Start

```bash
nvim                         # open Neovim
cd ~/dotfiles && tmux        # start tmux in a project/config directory
```

- Neovim files: `<Space><Space>`; repository search: `<Space>sg`.
- Harpoon: `<Space>ha` add, `<Space>hh` list, `<Space>h1`–`h4` jump.
- Definition/reference: `gd` / `gr`; format Python: `<Space>cf`.
- Run/debug Python: `<Space>t` tests, `<Space>dc` current file, `<Space>db` breakpoint, `F5/F9/F10/F11` continue/break/over/into.
- Codex in Neovim: `<Space>ai`; send context: `<Space>as`.
- tmux prefix is `Ctrl+A`: `|` split side-by-side, `-` split top/bottom, `z` zoom, `c` new window, `,` rename window, `f` pick/switch project, `d` detach.
- tmux pane navigation: `Ctrl+H/J/K/L`; resize: `Alt+H/J/K/L`.
- Save workspace: `Ctrl+A`, then `Ctrl+S`; restore: `Ctrl+A`, then `Ctrl+R`. Continuum also snapshots every five minutes; a new tmux server restores the last snapshot.

See [Neovim cheatsheet](nvim/CHEATSHEET.md) and [tmux cheatsheet](tmux/CHEATSHEET.md) for details.
