return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = { style = "moon", styles = { sidebars = "dark", floats = "dark" } },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "tokyonight" } } },
  {
    "stevearc/oil.nvim",
    opts = { view_options = { show_hidden = true } },
    keys = { { "<leader>o", "<cmd>Oil<cr>", desc = "Oil file manager" } },
  },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  { "ThePrimeagen/vim-be-good", cmd = "VimBeGood", lazy = true },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    keys = {
      { "<leader>h", false },
      { "<leader>1", false },
      { "<leader>2", false },
      { "<leader>3", false },
      { "<leader>4", false },
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Add file",
      },
      {
        "<leader>hh",
        function()
          require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
        end,
        desc = "Show marks",
      },
      {
        "<leader>h1",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "Mark 1",
      },
      {
        "<leader>h2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Mark 2",
      },
      {
        "<leader>h3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Mark 3",
      },
      {
        "<leader>h4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Mark 4",
      },
      {
        "<leader>hn",
        function()
          require("harpoon"):list():next()
        end,
        desc = "Next mark",
      },
      {
        "<leader>hp",
        function()
          require("harpoon"):list():prev()
        end,
        desc = "Previous mark",
      },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "lewis6991/async.nvim" },
    opts = {},
    keys = {
      {
        "<leader>rs",
        function()
          require("refactoring").select_refactor()
        end,
        mode = { "n", "x" },
        desc = "Select refactor",
      },
      {
        "<leader>re",
        function()
          return require("refactoring").extract_func()
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Extract function",
      },
      {
        "<leader>rv",
        function()
          return require("refactoring").extract_var()
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Extract variable",
      },
      {
        "<leader>ri",
        function()
          return require("refactoring").inline_var()
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Inline variable",
      },
    },
  },
  { "folke/sidekick.nvim", opts = { nes = { enabled = false } } },
}
