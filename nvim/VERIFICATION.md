# Verification report

Last run: 2026-11-01, Ubuntu 22.04 WSL2, x86_64.

## Passed

- Neovim 0.12.6 stable release installed; official archive SHA-256 verified.
- LazyVim starter loads, Lazy.nvim initialized, and `lazy-lock.json` was generated.
- Plugin API smoke check loaded Harpoon2, refactoring.nvim, nvim-dap, dap-ui, neotest, and conform; Tokyo Night Moon and true color were active.
- Tree-sitter current CLI is installed; supported parsers including Python, C/C++, Rust, Lua, Bash, JSON, YAML, and Markdown installed. Python parser ABI 15.
- Python sample: `uv run pytest -q` passed (1 test); Ruff check and format check passed.
- Headless Python LSP attached both `basedpyright` and `ruff` to the sample.
- `:checkhealth` completed with `UIEnter` simulated: Snacks input/select, LazyGit, fzf, Tree-sitter, Neovim 0.12.6, and no deprecated API warnings. Optional image/diagram renderers and unused remote providers remain unavailable.
- Codex CLI, basedpyright, Ruff, isolated debugpy, uv, and Windows `win32yank.exe` are available.

## DAP UI and Python launch verification (2026-11-01)

- Reproduced the exact clean-process `Space d b` failure before the fix. The stack ended at `nvim-dap-ui/lua/dapui/init.lua:102`, where the second `dapui.setup()` attempted to delete an existing UI buffer while Lazy was loading the local `nvim-dap` spec.
- Confirmed `lua/config/lazy.lua` imports `lazyvim.plugins.extras.dap.core`; that official extra already owns `nvim-dap-ui.setup()` and its open/close listeners. The local `debug.lua` was doing a second setup and adding a second set of lifecycle callbacks. The Python extra also already inserts `file`, `file:args`, `attach`, and doctest configs; local `dap-python.setup()` had inserted a duplicate set.
- Removed the second DAP UI setup and event listeners; rounded-float configuration now extends the LazyVim-owned UI opts. The Python adapter is repointed to the dedicated debugpy environment with `include_configs=false`, preserving the extra's single launch-config list.
- `Space d b` set and removed a breakpoint in a clean Neovim process with no config error. The Python `file` launch configuration count was exactly one.
- `Space d c` launched the current Python file directly, stopped at its breakpoint, and returned `u=2`, `v=3`, `w=4`, and `dist` through debugpy. The scopes panel contained the local values.
- DAP UI evaluations rendered `v = 3`, `dist[v] = 30`, and `(u, v, w) = (2, 3, 4)`. The DAP REPL returned tuple and `dist[v]` results.
- Step over refreshed `total` to `39`; termination and a second mapped launch/stop/termination passed.
- The adapter callback was inspected and verified to launch `~/.local/share/nvim/debugpy/bin/python -m debugpy.adapter`, independently from the target project's Python interpreter.
- Final log scan contained none of E565, missing-buffer, REPL index, `No configuration selected`, or stack retrieval errors. Test used the real Neovim config and real debugpy, in headless mode; terminal rendering/input was not visually inspected.

## Not yet verified interactively

- Pytest method/class debugging and attach-to-process still need terminal confirmation. The earlier sample pytest execution passed independently.
- Windows Terminal Nerd Font rendering and clipboard round trip require a Windows Terminal session.
- Harpoon add/list/navigation and Codex CLI sign-in/session require interactive terminal use.

## Known limits

- `git-worktree.nvim` was evaluated and omitted because the upstream v2 effort remains unresolved and the plugin overlaps existing Git workflows. LazyGit and LazyVim Git remain available. Fugitive was omitted as duplicate Git UI. `vim-be-good` is optional and manually invoked.
- Install JetBrainsMono Nerd Font on Windows and select it in Windows Terminal's Ubuntu profile to render icons correctly.
