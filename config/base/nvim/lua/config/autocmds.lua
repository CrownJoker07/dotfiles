-- AUTOCOMMANDS
local map = vim.keymap.set

-- Autoread when file changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "checktime",
})

-- Highlight when yanking
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

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP keymaps",
  callback = function(event)
    local function lsp_map(keys, func, desc)
      map("n", keys, func, {
        buffer = event.buf,
        desc = desc,
      })
    end

    lsp_map("gd", vim.lsp.buf.definition, "Go to definition")
    lsp_map("gD", vim.lsp.buf.declaration, "Go to declaration")
    lsp_map("gr", vim.lsp.buf.references, "Go to references")
    lsp_map("gi", vim.lsp.buf.implementation, "Go to implementation")
    lsp_map("gt", vim.lsp.buf.type_definition, "Go to type definition")
    lsp_map("K", vim.lsp.buf.hover, "Hover documentation")
    lsp_map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    lsp_map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})

-- USER COMMANDS
vim.api.nvim_create_user_command("GitBlameLine", function()
  local line_number = vim.fn.line(".")
  local filename = vim.api.nvim_buf_get_name(0)

  if filename == "" then
    print("No file name")
    return
  end

  local result = vim.system({
    "git",
    "blame",
    "-L",
    line_number .. ",+1",
    filename,
  }):wait()

  print(result.stdout)
end, { desc = "Print the git blame for the current line" })
