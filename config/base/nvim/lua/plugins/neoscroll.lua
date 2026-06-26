local modes = { "n", "v", "x" }

return {
  {
    "karb94/neoscroll.nvim",
    opts = {
      -- Disable built-in mappings so the custom timings below define the exact scroll feel.
      mappings = {},
      easing = "quadratic",
    },
    keys = {
      {
        "<C-u>",
        function()
          require("neoscroll").ctrl_u({ duration = 100 })
        end,
        desc = "Smooth scroll half page up",
        mode = modes,
      },
      {
        "<C-d>",
        function()
          require("neoscroll").ctrl_d({ duration = 100 })
        end,
        desc = "Smooth scroll half page down",
        mode = modes,
      },
      {
        "<C-b>",
        function()
          require("neoscroll").ctrl_b({ duration = 200 })
        end,
        desc = "Smooth scroll page up",
        mode = modes,
      },
      {
        "<C-f>",
        function()
          require("neoscroll").ctrl_f({ duration = 200 })
        end,
        desc = "Smooth scroll page down",
        mode = modes,
      },
      {
        "<C-y>",
        function()
          require("neoscroll").scroll(-0.1, { move_cursor = false, duration = 50 })
        end,
        desc = "Smooth scroll window up",
        mode = modes,
      },
      {
        "<C-e>",
        function()
          require("neoscroll").scroll(0.1, { move_cursor = false, duration = 50 })
        end,
        desc = "Smooth scroll window down",
        mode = modes,
      },
      {
        "zt",
        function()
          require("neoscroll").zt({ half_win_duration = 100 })
        end,
        desc = "Smooth center cursor at top",
        mode = modes,
      },
      {
        "zz",
        function()
          require("neoscroll").zz({ half_win_duration = 100 })
        end,
        desc = "Smooth center cursor",
        mode = modes,
      },
      {
        "zb",
        function()
          require("neoscroll").zb({ half_win_duration = 100 })
        end,
        desc = "Smooth center cursor at bottom",
        mode = modes,
      },
    },
  },
}
