local map = vim.keymap.set

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
    map("n", "grd", vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = "Go to definition",
    })
  end,
})

do
  local excluded = {
    gitcommit = true,
    gitrebase = true,
    lazy = true,
    mason = true,
    help = true,
    qf = true,
  }

  local timers = {}
  local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })

  local function cancel_timer(buf)
    if timers[buf] then
      timers[buf]:close()
      timers[buf] = nil
    end
  end

  local function save(buf)
    if not vim.bo[buf].modified then
      return
    end
    vim.cmd("silent! write")
  end

  local function defer_save(buf)
    cancel_timer(buf)
    timers[buf] = vim.defer_fn(function()
      save(buf)
      timers[buf] = nil
    end, 1000)
  end

  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = group,
    callback = function(args)
      if excluded[vim.bo.filetype] or not vim.bo.modifiable then
        return
      end
      defer_save(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "QuitPre" }, {
    group = group,
    callback = function(args)
      if excluded[vim.bo.filetype] or not vim.bo.modifiable then
        return
      end
      save(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function(args)
      cancel_timer(args.buf)
    end,
  })

  vim.api.nvim_create_user_command("ASToggle", function()
    local active = #vim.api.nvim_get_autocmds({ group = group }) > 0
    if active then
      vim.api.nvim_clear_autocmds({ group = group })
      for _, t in pairs(timers) do
        t:close()
      end
      timers = {}
      vim.notify("Auto-save off", vim.log.levels.INFO)
    else
      vim.notify("Auto-save on -- restart required", vim.log.levels.INFO)
    end
  end, { desc = "Toggle auto-save" })
end
