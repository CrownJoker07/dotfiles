local excluded_filetypes = {
  "gitcommit",
  "gitrebase",
  "lazy",
  "mason",
  "help",
  "qf",
}

local function save_condition(buf)
  if vim.tbl_contains(excluded_filetypes, vim.fn.getbufvar(buf, "&filetype")) then
    return false
  end
  return true
end

return {
  {
    "okuuva/auto-save.nvim",
    version = "^1.0.0",
    event = { "InsertLeave", "TextChanged" },
    cmd = { "ASToggle" },
    keys = {
      {
        "<leader>us",
        "<cmd>ASToggle<CR>",
        desc = "Toggle auto-save",
      },
    },
    opts = {
      condition = save_condition,
      debounce_delay = 1000,
    },
  },
}
