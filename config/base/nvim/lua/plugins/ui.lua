return {
  -- Show available keymaps after pressing <leader>
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
        { "<leader>r", group = "rename" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>w", group = "window/write" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer local keymaps",
      },
    },
  },

  -- Status line
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

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    keys = {
      { "<C-u>", function() require("neoscroll").ctrl_u({ duration = 100, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "<C-d>", function() require("neoscroll").ctrl_d({ duration = 100, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "<C-b>", function() require("neoscroll").ctrl_b({ duration = 200, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "<C-f>", function() require("neoscroll").ctrl_f({ duration = 200, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "<C-y>", function() require("neoscroll").scroll(-0.1, { move_cursor = false, duration = 50, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "<C-e>", function() require("neoscroll").scroll(0.1, { move_cursor = false, duration = 50, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "zt", function() require("neoscroll").zt({ half_win_duration = 100, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "zz", function() require("neoscroll").zz({ half_win_duration = 100, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
      { "zb", function() require("neoscroll").zb({ half_win_duration = 100, easing = "quadratic" }) end, mode = { "n", "v", "x" } },
    },
  },

  -- Better diagnostics / references / quickfix UI
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
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP definitions/references" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
    },
  },
}
