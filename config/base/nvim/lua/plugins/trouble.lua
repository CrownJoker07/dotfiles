return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      modes = {
        symbols = {
          focus = true,
          win = {
            type = "float",
            relative = "editor",
            position = { 0, 0 },
            size = { width = 1.0, height = 1.0 },
            border = "none",
          },
          keys = {
            ["<cr>"] = "jump_close",
          },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<CR>", desc = "Symbols" },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
        desc = "LSP definitions/references",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
    },
  },
}
