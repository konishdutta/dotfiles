#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
nvim --version | head -n 3
nvim --headless '+lua assert(vim.g.colors_name == "tokyonight-moon"); assert(vim.opt.termguicolors:get()); assert(require("harpoon"):list()); assert(require("dap").continue); assert(require("dapui").toggle); assert(require("refactoring").select_refactor); assert(require("neotest").run); print("PLUGIN_API_CHECKS_OK")' +qa
cd "$root/docs/python-debug-sample"
uv run pytest -q
uv run ruff check .
uv run ruff format --check .
