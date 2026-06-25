return {
  {
    "karb94/neoscroll.nvim",
    opts = {
      mappings = {},
      easing = "quadratic",
    },
    keys = {
      {
        "<C-u>",
        function()
          require("neoscroll").ctrl_u({ duration = 100 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "<C-d>",
        function()
          require("neoscroll").ctrl_d({ duration = 100 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "<C-b>",
        function()
          require("neoscroll").ctrl_b({ duration = 200 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "<C-f>",
        function()
          require("neoscroll").ctrl_f({ duration = 200 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "<C-y>",
        function()
          require("neoscroll").scroll(-0.1, { move_cursor = false, duration = 50 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "<C-e>",
        function()
          require("neoscroll").scroll(0.1, { move_cursor = false, duration = 50 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "zt",
        function()
          require("neoscroll").zt({ half_win_duration = 100 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "zz",
        function()
          require("neoscroll").zz({ half_win_duration = 100 })
        end,
        mode = { "n", "v", "x" },
      },
      {
        "zb",
        function()
          require("neoscroll").zb({ half_win_duration = 100 })
        end,
        mode = { "n", "v", "x" },
      },
    },
  },
}
