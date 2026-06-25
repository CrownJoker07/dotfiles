vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  callback = function()
    if vim.hl and vim.hl.on_yank then
      vim.hl.on_yank()
    else
      vim.highlight.on_yank()
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP keymaps",
  callback = function(event)
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = "Go to definition",
    })
  end,
})

do
  local group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = group,
    callback = function()
      if vim.fn.mode() ~= "c" then
        vim.cmd("checktime")
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group,
    callback = function()
      vim.notify("File changed on disk, buffer reloaded", vim.log.levels.INFO)
    end,
  })
end
