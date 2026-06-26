local yank_group = vim.api.nvim_create_augroup("HighlightYank", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = yank_group,
  desc = "Highlight when yanking text",
  callback = function()
    if vim.hl and vim.hl.on_yank then
      vim.hl.on_yank()
    else
      vim.highlight.on_yank()
    end
  end,
})

local lsp_group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  desc = "LSP keymaps",
  callback = function(event)
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = "Go to definition",
    })
  end,
})

local reload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = reload_group,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = reload_group,
  callback = function()
    vim.notify("File changed on disk, buffer reloaded", vim.log.levels.INFO)
  end,
})
