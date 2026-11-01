return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "python",
        "query",
        "lua",
        "bash",
        "c",
        "cpp",
        "rust",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "toml",
        "vim",
        "vimdoc",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.basedpyright =
        { settings = { basedpyright = { analysis = { typeCheckingMode = "standard", diagnosticMode = "workspace" } } } }
      opts.servers.lua_ls = {}
      opts.servers.bashls = {}
      opts.servers.ruff = {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      }
    end,
  },
  { "mason-org/mason.nvim", opts = { PATH = "append", ensure_installed = { "shellcheck", "shfmt", "clang-format" } } },
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-python" },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-python"] = { runner = "pytest" }
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "ruff_format", "ruff_organize_imports" }
    end,
  },
}
