local excluded_filetypes = {
  gitcommit = true,
  gitrebase = true,
  help = true,
  lazy = true,
  mason = true,
  qf = true,
}

local timers = {}
local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })
local enabled = true

local function cancel_timer(buf)
  local timer = timers[buf]
  if timer then
    if not timer:is_closing() then
      timer:close()
    end
    timers[buf] = nil
  end
end

local function can_save(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.api.nvim_buf_is_loaded(buf)
    and vim.api.nvim_buf_get_name(buf) ~= ""
    and vim.bo[buf].buftype == ""
    and vim.bo[buf].modifiable
    and not vim.bo[buf].readonly
    and not excluded_filetypes[vim.bo[buf].filetype]
end

local function save(buf)
  if not can_save(buf) or not vim.bo[buf].modified then
    return
  end

  vim.api.nvim_buf_call(buf, function()
    local ok, err = pcall(vim.cmd, "silent write")
    if not ok then
      vim.notify("Auto-save failed: " .. tostring(err), vim.log.levels.ERROR)
    end
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

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      cancel_timer(args.buf)
    end,
  })
end

local function cancel_all_timers()
  for buf in pairs(timers) do
    cancel_timer(buf)
  end
end

setup_autocmds()

vim.api.nvim_create_user_command("ASToggle", function()
  enabled = not enabled

  if enabled then
    setup_autocmds()
    vim.notify("Auto-save on", vim.log.levels.INFO)
  else
    vim.api.nvim_clear_autocmds({ group = group })
    cancel_all_timers()
    vim.notify("Auto-save off", vim.log.levels.INFO)
  end
end, { desc = "Toggle auto-save" })
