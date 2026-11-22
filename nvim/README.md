# Neovim on WSL2

A modular LazyVim starter setup for Ubuntu 22.04 / WSL2. LazyVim and its official extras provide the LSP, Mason, completion, Snacks picker/explorer, diagnostics, sessions, Git signs, terminal, formatting, and key discovery. Tokyo Night Moon, Oil, Harpoon2, refactoring, UndoTree, DAP, and Sidekick Codex are configured in `lua/`. Plugin revisions are pinned in `lazy-lock.json`.

## Start and navigate

Run `nvim` from a WSL terminal. Find files with `<Space><Space>` and search repository text with `<Space>sg`. Use `<Space>e` for the explorer, `<Space>o` for Oil, and `<Space>ha` / `<Space>hh` to add/list Harpoon marks. Jump to marks with `<Space>h1` through `<Space>h4`; cycle with `<Space>hn` and `<Space>hp`. `gd` goes to a definition, `gr` to references, `K` shows hover, and `<Space>cf` formats the current buffer.

Python tests use `<Space>t` and the neotest menu; `uv run pytest` also works in the included sample. Python formatting uses Ruff. LSP selection is basedpyright plus Ruff, with Ruff hover disabled to avoid duplicate hover.

## Python debugging

`<F5>` and `<Space>dc` launch the current Python file when idle and continue an active session; `<F9>` toggles a breakpoint, `<F10>` steps over, `<F11>` steps into, and `<Shift-F11>` steps out. Use `<Space>db/do/di/dO` if a terminal captures function keys; `<Space>du` toggles the UI, `<Space>dr` opens the REPL, `<Space>dn` debugs the nearest pytest test, `<Space>dC` the class, `<Space>dM` a Python module, and `<Space>dA` attaches to debugpy on localhost. `<Space>cv` selects an interpreter.

The debug adapter runs from `~/.local/share/nvim/debugpy`, separately from the target interpreter. Target resolution is selected interpreter, active `VIRTUAL_ENV`, active `CONDA_PREFIX`, project `.venv` / `venv` / `env`, then `python3`. Launch defaults are `justMyCode=true` and `subProcess=true`; change these in `lua/plugins/debug.lua`. Run the sample with `cd ~/.config/nvim/docs/python-debug-sample && uv run pytest -q`. To manually verify debugging, open `tests/test_compute.py`, set a breakpoint inside `test_summarize` with `<Space>db`, then use `<Space>dn` or `<Space>dc`; confirm the DAP UI opens, inspect locals, step, and continue. For the current file with arguments, choose `file:args` from the DAP configuration picker; `<Space>dM` launches a module and prompts for module name and arguments.

For Triton interpreter debugging, choose `Triton Interpreter` in the DAP
configuration picker. It launches the current file with `TRITON_INTERPRET=1`
and allows stepping into user code outside the current file. This requires a
project interpreter with Triton installed. To debug a `@triton.jit` kernel,
set a breakpoint on a kernel statement and run a small input that invokes it.

## Codex and terminal

`<Space>ai` toggles the interactive Codex CLI; `<Space>as` sends the current file/selection context. Codex remains independently available by running `codex` in a WSL terminal. `<Space>at` toggles the integrated terminal, and `<Space>gg` opens LazyGit.

## Maintenance

Run `scripts/bootstrap.sh` to install pinned user-local base tools, `scripts/smoke-test.sh` for smoke checks, `:Lazy` to inspect plugins, `:Mason` for language tools, `:Lazy sync` to restore pinned plugins, and `:Lazy update` to update them. Review and preserve the resulting `lazy-lock.json` in version control. `VERIFICATION.md` distinguishes executed checks from interactive checks.

## WSL and appearance

Files/configuration belong in the Linux filesystem; keep repositories in their current locations. `win32yank.exe` provides the Windows clipboard bridge. Install JetBrainsMono Nerd Font on Windows, then choose it under Windows Terminal Settings → Ubuntu profile → Appearance → Font face; restart the profile. The setup does not change Windows Terminal settings or shell startup files (rustup may have added its standard cargo environment line to `~/.profile`).

## Plugin choices

The official LazyVim extras cover Python, C/C++, Rust, JSON/YAML, Markdown, TypeScript, DAP, Harpoon2, and refactoring. Lua and Bash LSP/tooling are configured directly; Tree-sitter uses its current 0.12-compatible main branch and asynchronous installer. `git-worktree.nvim` was not added: upstream v2 work is unresolved and a separate worktree UI overlaps the included Git workflow. Fugitive also duplicates LazyVim Git/LazyGit. `vim-be-good` is lazy and can be started with `:VimBeGood`.
