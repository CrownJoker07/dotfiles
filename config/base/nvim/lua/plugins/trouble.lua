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
          -- Use Trouble as a full-screen symbol navigator, closing after jump.
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
      {
        "<leader>xx",
        function()
          require("trouble").toggle("diagnostics")
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>xX",
        function()
          require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } })
        end,
        desc = "Buffer diagnostics",
      },
      {
        "<leader>cs",
        function()
          require("trouble").toggle("symbols")
        end,
        desc = "Symbols",
      },
      {
        "<leader>cl",
        function()
          require("trouble").toggle({ mode = "lsp", focus = false, win = { position = "right" } })
        end,
        desc = "LSP definitions/references",
      },
      {
        "<leader>xL",
        function()
          require("trouble").toggle("loclist")
        end,
        desc = "Location list",
      },
      {
        "<leader>xQ",
        function()
          require("trouble").toggle("qflist")
        end,
        desc = "Quickfix list",
      },
    },
  },
}
