local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  desc = "Highlight when yanking text",
  callback = function()
    if vim.hl and vim.hl.on_yank then
      vim.hl.on_yank()
    else
      vim.highlight.on_yank()
    end
  end,
})

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_keymaps"),
  desc = "LSP keymaps",
  callback = function(event)
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = "Go to definition",
    })
  end,
})

local function can_checktime()
  return vim.fn.mode() ~= "c" and vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= ""
end

-- Auto reload
-- autoread does not watch files by itself; checktime triggers the reload check.
local auto_reload_group = augroup("auto_reload")

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
  group = auto_reload_group,
  desc = "Check for files changed outside Neovim",
  callback = function()
    if can_checktime() then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = auto_reload_group,
  desc = "Notify when a file is reloaded after external changes",
  callback = function()
    vim.notify("File changed on disk, buffer reloaded", vim.log.levels.INFO)
  end,
})
