local excluded_filetypes = {
  gitcommit = true,
  gitrebase = true,
  help = true,
  lazy = true,
  mason = true,
  NvimTree = true,
  qf = true,
}

local excluded_buftypes = {
  acwrite = true,
  nofile = true,
  prompt = true,
  terminal = true,
}

local function can_auto_save(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end

  if vim.api.nvim_buf_get_name(buf) == "" then
    return false
  end

  if excluded_buftypes[vim.bo[buf].buftype] then
    return false
  end

  if excluded_filetypes[vim.bo[buf].filetype] then
    return false
  end

  return vim.bo[buf].modifiable and not vim.bo[buf].readonly
end

return {
  {
    "okuuva/auto-save.nvim",
    version = "^1.0.0",
    event = {
      "InsertLeave",
      "TextChanged",
    },
    cmd = {
      "ASToggle",
      "ASEnable",
      "ASDisable",
      "ASStatus",
    },
    opts = {
      debounce_delay = 500,
      condition = can_auto_save,
    },
    config = function(_, opts)
      local autosave = require("auto-save")

      autosave.setup(opts)

      vim.api.nvim_create_user_command("ASEnable", function()
        autosave.on()
        vim.notify("Auto-save on", vim.log.levels.INFO)
      end, { desc = "Enable auto-save" })

      vim.api.nvim_create_user_command("ASDisable", function()
        autosave.off()
        vim.notify("Auto-save off", vim.log.levels.INFO)
      end, { desc = "Disable auto-save" })

      vim.api.nvim_create_user_command("ASStatus", function()
        local status = autosave.enabled() and "on" or "off"
        vim.notify("Auto-save " .. status, vim.log.levels.INFO)
      end, { desc = "Show auto-save status" })
    end,
  },
}
