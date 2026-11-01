-- Bridge LazyVim's persistence.nvim state files to tmux-resurrect's exact
-- contract: a readable Session.vim in the restored pane's working directory.
-- The bridge is a symlink; it never replaces a user-owned file or outside link.
local uv = vim.uv
local interval_ms = 60 * 1000
local timer

local function has_named_file_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      return true
    end
  end
  return false
end

local function link_resurrect_session(persistence)
  if not vim.env.TMUX or vim.env.TMUX == "" then
    return
  end
  local session = persistence.current()
  if not uv.fs_stat(session) then
    return
  end

  local cwd = vim.fn.getcwd()
  local alias = vim.fs.joinpath(cwd, "Session.vim")
  local stat = uv.fs_lstat(alias)
  if not stat then
    uv.fs_symlink(session, alias)
    return
  end
  if stat.type ~= "link" then
    return -- Never overwrite a regular user-owned Session.vim.
  end

  local target = uv.fs_readlink(alias)
  local owned_dir = vim.fs.normalize(vim.fn.stdpath("state") .. "/sessions") .. "/"
  if target and target:sub(1, #owned_dir) == owned_dir and target ~= session then
    uv.fs_unlink(alias)
    uv.fs_symlink(session, alias)
  end
end

local function save_tmux_nvim_session()
  if not vim.env.TMUX or vim.env.TMUX == "" or not has_named_file_buffer() then
    return
  end
  local ok, persistence = pcall(require, "persistence")
  if not ok or not persistence.active() then
    return
  end
  -- persistence.nvim writes only a Neovim session description, never buffer text.
  local saved = pcall(persistence.save)
  if saved then
    link_resurrect_session(persistence)
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "PersistenceSavePost",
  callback = function()
    local ok, persistence = pcall(require, "persistence")
    if ok then
      link_resurrect_session(persistence)
    end
  end,
})

-- Save editor layout more often than tmux's 5-minute workspace snapshot so an
-- abrupt WSL shutdown can still restore recent files, tabs, splits and cursors.
timer = uv.new_timer()
if timer then
  timer:start(interval_ms, interval_ms, function()
    vim.schedule(save_tmux_nvim_session)
  end)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function()
      if timer and not timer:is_closing() then
        timer:stop()
        timer:close()
      end
    end,
  })
end
