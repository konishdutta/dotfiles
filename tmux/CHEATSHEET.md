# tmux quick reference

Prefix is **Ctrl+A**. Press it twice to send Ctrl+A to the application.

## Start and sessions

- `tmux` — start or reattach to the default server.
- `tmux new -s NAME` — start a named session.
- `Ctrl+A d` — detach; programs keep running while WSL/tmux server remains alive.
- `Ctrl+A s` — browse sessions; `Ctrl+A (` / `)` — previous/next session.
- `Ctrl+A f` — fzf project selector; selects an existing project session or creates one in that project directory.

## Windows

- `Ctrl+A c` — new window in the current directory.
- `Ctrl+A ,` — rename current window.
- `Ctrl+A 1` … `9` — select window by number.
- `Ctrl+A n` / `p` — next / previous window; `Ctrl+A Tab` — last window.
- `Ctrl+A &` — close window (confirm).
- `Ctrl+A <` / `>` — reorder window left / right.

## Panes

- `Ctrl+A |` — split side by side; `Ctrl+A -` — split top/bottom. New panes inherit the current directory.
- `Ctrl+H/J/K/L` — move among tmux panes and Neovim splits.
- `Alt+H/J/K/L` — resize across Neovim/tmux boundaries. If Windows Terminal does not send Alt combinations, use `Ctrl+A` then `H/J/K/L` to resize.
- `Ctrl+A z` — zoom/unzoom current pane.
- `Ctrl+A x` — close pane (confirm).
- `Ctrl+A Space` — cycle pane layouts.

## Copy and scrollback

- Mouse wheel scrolls; click-drag selects text.
- `Ctrl+A [` — vi copy mode; use `j/k`, `/` search, `v` begin selection, `y` copy, `q` exit.
- `Ctrl+Shift+V` — paste from Windows Terminal clipboard.
- tmux copy-mode and Neovim system clipboard both use the WSL `win32yank` bridge.

## Workspace save and restore

- `Ctrl+A` then `Ctrl+S` — save now; use before a planned Windows/WSL restart.
- `Ctrl+A` then `Ctrl+R` — manually restore the latest snapshot.
- Automatic snapshot: every five minutes while a tmux client is attached (Continuum evaluates its status-line hook). Before rebooting, especially after detaching, reattach or save manually. On reboot, reopen Ubuntu and run `tmux`; restore runs when the new server starts.
- Detach does not stop programs. Windows shutdown does; tmux recreates safe shells/layouts but does not restart training, debugger, Codex, or service processes.

## Neovim and maintenance

- `nvim` — open Neovim in the current pane.
- `Ctrl+H/J/K/L` crosses the Neovim/tmux boundary; `Alt+H/J/K/L` resizes.
- `Ctrl+A r` — reload tmux config.
- `Ctrl+A I` — install TPM plugins; `Ctrl+A U` — update plugins.
- Font symbols: install JetBrainsMono Nerd Font in Windows and select it at **Windows Terminal Settings → Ubuntu profile → Appearance → Font face**.
- See `README.md` for limitations, restore troubleshooting, and the Neovim `Session.vim` bridge.
