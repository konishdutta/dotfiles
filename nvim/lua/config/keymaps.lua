local map = vim.keymap.set
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzz", { desc = "Next match centered" })
map("n", "N", "Nzz", { desc = "Previous match centered" })
map("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })
map("x", "p", '"_dP', { desc = "Paste and keep yank register" })
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard", remap = true })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
map({ "n", "x" }, "<leader>P", '"+p', { desc = "Paste from clipboard" })
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Undo tree" })
map("n", "<leader>gg", function()
  Snacks.lazygit()
end, { desc = "LazyGit" })
map("n", "<leader>ai", function()
  require("sidekick.cli").toggle({ name = "codex" })
end, { desc = "Toggle Codex" })
map("n", "<leader>as", function()
  require("sidekick.cli").send({ msg = "Please help with the selected code in {file}:\n{selection}" })
end, { desc = "Send context to Codex" })
require("which-key").add({
  { "<leader>f", group = "Search and find" },
  { "<leader>e", group = "Files" },
  { "<leader>h", group = "Harpoon" },
  { "<leader>g", group = "Git" },
  { "<leader>x", group = "Diagnostics" },
  { "<leader>r", group = "Refactoring" },
  { "<leader>d", group = "Debugging" },
  { "<leader>t", group = "Testing" },
  { "<leader>a", group = "Terminal and AI" },
  { "<leader>w", group = "Windows" },
})
map("n", "<leader>at", function()
  Snacks.terminal()
end, { desc = "Terminal" })
