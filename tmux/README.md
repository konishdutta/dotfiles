# WSL tmux environment

A compact, user-managed tmux setup for Ubuntu on WSL2 and Windows Terminal. The canonical configuration is `~/.config/tmux/tmux.conf`; `~/.tmux.conf` points to it for compatibility. TPM plugins are kept under `~/.tmux/plugins` and exposed through `~/.config/tmux/plugins` for XDG-aware TPM releases.

## Installed components

- tmux 3.8, built from the official tmux release into `~/.local/opt/tmux-3.8` with a `~/.local/bin/tmux` entry point. Ubuntu's `/usr/bin/tmux` is untouched.
- TPM manages Tokyo Night tmux, tmux-resurrect, tmux-continuum, tmux-yank, and the Smart Splits v3 tmux backend.
- Tokyo Night is set to Moon. Continuum is last in the plugin list so its periodic save command remains in the theme's active `status-right`.
- ThePrimeagen's `tmux-sessionizer` is installed at `~/.local/bin/tmux-sessionizer`, with fzf for choosing projects. Session names add a path hash to the directory name so same-named projects remain distinct. Project hooks are disabled; choosing a project only switches to or creates its shell session. It never creates application-specific windows or pane layouts.
- Neovim uses the already installed LazyVim configuration. `lua/plugins/tmux.lua` configures Smart Splits v3 with `backend-tmux`; `lua/config/autocmds.lua` connects LazyVim persistence to tmux-resurrect's `Session.vim` strategy.

## Start and manage

`Ctrl+A h` / `Ctrl+A l` moves to the previous/next window. `escape-time` is set
to 50 ms to improve Windows Terminal escape-sequence and bracketed-paste
handling.

Open Ubuntu in Windows Terminal, `cd` to a directory if desired, then run `tmux`. Nothing launches tmux automatically on Windows boot. After a reboot, reopen Ubuntu and run `tmux`; Continuum restores at server startup from the last successful snapshot.

Make sessions and layouts yourself. `Ctrl+A c` makes a window, and `Ctrl+A |` / `Ctrl+A -` split the current directory. `Ctrl+A f` opens the fzf project switcher. Returning to an existing project session preserves its windows and panes.

The first plugin install is available with `Ctrl+A I` (capital I); update plugins with `Ctrl+A U` (capital U). Or run `~/.tmux/plugins/tpm/bin/install_plugins` and `~/.tmux/plugins/tpm/bin/update_plugins all` from a shell. Reload with `Ctrl+A r`.

## Persistence and recovery

Continuum snapshots every five minutes through its `status-right` hook. Keep a tmux client attached for periodic snapshots to be evaluated; when you have detached and are about to shut WSL down, reattach or save manually. A snapshot can therefore be almost five minutes old. Before a planned restart, invoke `Ctrl+A`, then `Ctrl+S` to save immediately; wait for the confirmation message or check `~/.tmux/resurrect/last`. `Ctrl+A`, then `Ctrl+R` manually restores the snapshot. Automatic restore is enabled only when a new tmux server starts. Continuum boot launching is disabled.

Resurrect restores session names, windows and their ordering/names, pane splits and approximate proportions, working directories, active selections, and zoom state when supported. Pane dimensions adapt to the new terminal size. It captures visible pane text, but does not resume arbitrary processes. Only tmux-resurrect's conservative built-in process allowlist is used: Python training, debuggers, Codex, and services are deliberately not restarted. Shells are recreated.

### Neovim sessions

LazyVim's `persistence.nvim` writes session files under Neovim's state directory, not `Session.vim`. The small bridge saves an editor session every minute while Neovim runs inside tmux and links that state file as `Session.vim` in the pane's current directory. This satisfies resurrect's `nvim -S Session.vim` strategy. It creates that link only when the name is unused or already points into Neovim's own session directory; a regular user `Session.vim` and external symlink are left alone. The link can appear as an untracked file in a repository; remove it yourself only if you no longer want tmux to restore that editor session.

Neovim sessions restore file buffers, tabs, splits, and cursor positions where the session can reopen the files. They do not preserve unsaved buffer contents, active debugger state, terminal process state, or Codex's running conversation process. Neovim does not delete swap files; after an unclean shutdown, resolve any swap-file recovery prompt yourself. Multiple Neovim processes editing the same working directory use the same LazyVim session path, so the latest save wins.

## WSL and Windows Terminal

The installed Windows `win32yank.exe` is used by both tmux-yank and the Neovim system clipboard integration. tmux's copy-mode selection reaches the Windows clipboard; Windows Terminal's ordinary paste shortcut remains `Ctrl+Shift+V`. Clipboard round-trip was verified from WSL.

For powerline and Nerd Font symbols, install **JetBrainsMono Nerd Font** on Windows, then in Windows Terminal open **Settings → Ubuntu profile → Appearance → Font face**, select the installed Nerd Font, and restart that terminal tab. This Windows UI step was not changed by the Linux setup. The installed font face cannot be confirmed from WSL; validate symbols in the terminal after selecting it.

Check `echo "$TERM"` in an actual Windows Terminal tab. The automation shell used for installation reported `dumb`; if your Ubuntu tab does too, start tmux with `TERM=xterm-256color tmux` (this is a one-command override and does not edit shell files). The tmux configuration advertises RGB support and uses `tmux-256color` inside tmux. If function keys are intercepted by a host shortcut, use Neovim's leader-key debugger shortcuts alongside F5/F9/F10/F11.

## Files and maintenance

- `tmux.conf` — options, bindings, plugin order.
- `CHEATSHEET.md` — daily controls.
- `VERIFICATION.md` — executed checks and manual items.
- `tests/verify-isolated.sh` — end-to-end persistence test. It creates a unique tmux socket and uses a temporary save directory, then removes both.
- `~/.config/nvim/lua/plugins/tmux.lua` — Neovim half of Smart Splits.
- `~/.config/nvim/lua/config/autocmds.lua` — Neovim session bridge.

The dedicated `~/.config/tmux` directory is initialized as a Git repository for tracking your edits (no commit was created). To update tmux plugins, press `Ctrl+A U`. To update tmux itself, obtain the next stable source release from [the official tmux releases](https://github.com/tmux/tmux/releases), build into a versioned `~/.local/opt/tmux-X.Y` directory, then repoint `~/.local/bin/tmux` after verifying the new binary. The existing configuration and snapshots are separate from that binary. After changing TPM plugin configuration, run `Ctrl+A I` to install newly declared plugins.

To troubleshoot restoration, run `tmux show-option -g status-right` and confirm it contains `continuum_save.sh`; confirm continuum appears last in `tmux.conf`; inspect `~/.tmux/resurrect/last` and the latest timestamped snapshot. Manual restore is `Ctrl+A Ctrl+R`. Continuum only restores on a fresh server, not when attaching to an already running tmux server.
