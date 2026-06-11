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
          })
        end

        gs_map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, "Next git hunk")

        gs_map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, "Previous git hunk")

        gs_map("n", "<leader>gp", gitsigns.preview_hunk, "Preview git hunk")
        gs_map("n", "<leader>gb", gitsigns.blame_line, "Git blame line")
        gs_map("n", "<leader>gr", gitsigns.reset_hunk, "Reset git hunk")
        gs_map("n", "<leader>gs", gitsigns.stage_hunk, "Stage git hunk")
      end,
    },
  },
}
