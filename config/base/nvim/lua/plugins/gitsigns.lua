return {
  {
    "lewis6991/gitsigns.nvim",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local map = vim.keymap.set

        local function gs_map(mode, lhs, rhs, desc)
          map(mode, lhs, rhs, {
            buffer = bufnr,
            desc = desc,
            silent = true,
          })
        end

        local function nav_hunk(direction, diff_key)
          if vim.wo.diff then
            vim.cmd.normal({ diff_key, bang = true })
          else
            gitsigns.nav_hunk(direction)
          end
        end

        gs_map("n", "]c", function()
          nav_hunk("next", "]c")
        end, "Next git hunk")

        gs_map("n", "[c", function()
          nav_hunk("prev", "[c")
        end, "Previous git hunk")

        gs_map("n", "<leader>gp", gitsigns.preview_hunk, "Preview git hunk")
        gs_map("n", "<leader>gb", gitsigns.blame_line, "Git blame line")
        gs_map("n", "<leader>gr", gitsigns.reset_hunk, "Reset git hunk")
        gs_map("n", "<leader>gs", gitsigns.stage_hunk, "Stage git hunk")

        gs_map("v", "<leader>gr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selected git hunk")

        gs_map("v", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selected git hunk")
      end,
    },
  },
}
