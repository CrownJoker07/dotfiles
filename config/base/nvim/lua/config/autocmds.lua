local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

local lsp_completion_group = augroup("lsp_completion")
local completion_trigger_chars = {}
for i = 32, 126 do
  table.insert(completion_trigger_chars, string.char(i))
end

local function should_trigger_completion(char)
  return char ~= "" and char:match("[%w_%.:]") ~= nil
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

-- Native LSP completion
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_completion_group,
  desc = "Enable native LSP completion",
  callback = function(event)
    if not vim.lsp.completion then
      return
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
      client.server_capabilities.completionProvider.triggerCharacters = completion_trigger_chars
      vim.lsp.completion.enable(true, client.id, event.buf, {
        autotrigger = true,
      })

      if not vim.b[event.buf].native_lsp_completion_trigger then
        vim.b[event.buf].native_lsp_completion_trigger = true

        vim.api.nvim_create_autocmd("InsertCharPre", {
          group = lsp_completion_group,
          buffer = event.buf,
          desc = "Trigger native LSP completion after typing",
          callback = function()
            if vim.fn.pumvisible() == 1 or not should_trigger_completion(vim.v.char) then
              return
            end

            local bufnr = vim.api.nvim_get_current_buf()
            vim.schedule(function()
              if vim.api.nvim_get_current_buf() == bufnr and vim.lsp.completion then
                vim.lsp.completion.get()
              end
            end)
          end,
        })
      end
    end
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
