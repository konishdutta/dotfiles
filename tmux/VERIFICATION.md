# tmux environment verification report

Date: 2026-11-01 (UTC environment date). Tests were run in Ubuntu/WSL with disposable tmux sockets and `/tmp` data where noted.

## Passed

- Installed tmux reports `tmux 3.8`; executable resolves to `~/.local/bin/tmux`. System `/usr/bin/tmux` was not replaced.
- Loaded the production configuration on isolated servers: prefix `C-a`, window/pane base 1, auto-renumber, 50,000 line history, Moon theme, Continuum restore `on`, save interval 5. Window creation/reorder/renumber and pane resize/zoom commands also passed.
- Tokyo Night Moon produced a themed status line. Its `status-right` contains Continuum's `continuum_save.sh` hook, and the plugin is ordered after Tokyo Night.
- TPM initialized its XDG plugin directory; all declared TPM repositories were cloned: TPM, Tokyo Night tmux, resurrect, yank, Smart Splits tmux backend, and Continuum.
- Headless Neovim loaded both Smart Splits and its tmux backend; `:checkhealth smart-splits` completed.
- Launched configured Neovim inside an isolated tmux pane and observed `@pane-is-vim = 1`.
- Neovim persistence bridge created a `Session.vim` link to LazyVim's session file in a disposable project; a separate Neovim process restored the file buffer and three-line file through `nvim -S Session.vim`.
- Windows clipboard bridge round-trip succeeded with a unique sentinel, and the prior clipboard text was restored afterward.
- `tests/verify-isolated.sh` passed: same-basename projects produced distinct session names; project selection did not execute a `.tmux-sessionizer` hook; Continuum autosaved a changed layout at a one-minute test override; after killing and restarting the isolated server, both sessions, window names/order, active window and pane, split cwd, zoom state, and a second project cwd were restored.
- `bash -n` passed for the persistence test script and `nvim --headless +qa` started successfully. The persistence test used only a unique socket and temporary save directory; no real tmux server/session or production resurrect snapshot was touched.

## Not verified interactively

- Physical Ctrl+H/J/K/L movement across a live Neovim/tmux boundary and Alt resize. Backend integration and the Neovim-in-tmux marker were verified; actual Windows Terminal key delivery needs a terminal session.
- Nerd Font glyph rendering. Install/select JetBrainsMono Nerd Font on Windows Terminal per `README.md`.
- Mouse selection/scrolling and Windows Terminal paste interaction, beyond the WSL clipboard command round-trip.
- Actual five-minute elapsed production autosave. The production option was queried as `5`; the full autosave mechanism was exercised with an attached disposable client and isolated one-minute override to keep the test bounded. Continuum runs this hook through `status-right`; periodic saves require a tmux client/status line to evaluate it.
- State after an actual Windows reboot. An isolated tmux server restart exercised the same new-server Continuum restore path without rebooting the machine.
- Neovim debugger F-keys or runtime restoration. tmux-resurrect intentionally does not restart debugpy, training jobs, Codex, or services.

## Notes

The automation host's `TERM` was `dumb`; the disposable interactive client explicitly used `xterm-256color`. This does not change shell configuration. Windows Terminal should provide a color-capable TERM to WSL. See `README.md` for font, persistence, swap-file, and editor-session limitations.
