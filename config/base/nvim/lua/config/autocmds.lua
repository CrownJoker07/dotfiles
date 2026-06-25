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
  local enabled = true

  local function cancel_timer(buf)
    if timers[buf] then
      timers[buf]:close()
      timers[buf] = nil
    end
  end

  local function can_save(buf)
    return vim.api.nvim_buf_is_valid(buf)
      and vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].modifiable
      and not excluded[vim.bo[buf].filetype]
  end

  local function save(buf)
    if not can_save(buf) or not vim.bo[buf].modified then
      return
    end
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent! write")
    end)
  end

  local function defer_save(buf)
    cancel_timer(buf)
    timers[buf] = vim.defer_fn(function()
      timers[buf] = nil
      if enabled then
        save(buf)
      end
    end, 1000)
  end

  local function setup_autocmds()
    vim.api.nvim_clear_autocmds({ group = group })

    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
      group = group,
      callback = function(args)
        if can_save(args.buf) then
          defer_save(args.buf)
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "QuitPre" }, {
      group = group,
      callback = function(args)
        cancel_timer(args.buf)
        save(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      callback = function(args)
        cancel_timer(args.buf)
      end,
    })
  end

  setup_autocmds()

  vim.api.nvim_create_user_command("ASToggle", function()
    enabled = not enabled
    if not enabled then
      vim.api.nvim_clear_autocmds({ group = group })
      for _, t in pairs(timers) do
        t:close()
      end
      timers = {}
      vim.notify("Auto-save off", vim.log.levels.INFO)
    else
      setup_autocmds()
      vim.notify("Auto-save on", vim.log.levels.INFO)
    end
  end, { desc = "Toggle auto-save" })
end
