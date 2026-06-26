return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    opts = {
      options = {
        globalstatus = true,
        -- Keep the statusline visually flat.
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_b = { { "filename", path = 1 } },
      },
    },
  },
}
