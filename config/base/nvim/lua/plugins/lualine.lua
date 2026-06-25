return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_b = { { "filename", path = 1 } },
      },
    },
  },
}
