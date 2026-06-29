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
            vim.cmd.normal({ vim.v.count1 .. diff_key, bang = true })
          else
            gitsigns.nav_hunk(direction)
          end
        end

        local function selected_range()
          local first = vim.fn.line(".")
          local last = vim.fn.line("v")

          if first > last then
            first, last = last, first
          end

          return { first, last }
        end

        gs_map("n", "]c", function()
          nav_hunk("next", "]c")
        end, "Next git hunk")

        gs_map("n", "[c", function()
          nav_hunk("prev", "[c")
        end, "Previous git hunk")

        gs_map("n", "<leader>gp", gitsigns.preview_hunk, "Preview git hunk")
        gs_map("n", "<leader>gb", gitsigns.blame_line, "Git blame line")
        gs_map("n", "<leader>gB", gitsigns.toggle_current_line_blame, "Toggle git blame line")
        gs_map("n", "<leader>gd", gitsigns.diffthis, "Git diff current file")
        gs_map("n", "<leader>gq", gitsigns.setloclist, "Git hunks location list")
        gs_map("n", "<leader>gr", gitsigns.reset_hunk, "Reset git hunk")
        gs_map("n", "<leader>gs", gitsigns.stage_hunk, "Stage git hunk")

        gs_map("v", "<leader>gr", function()
          gitsigns.reset_hunk(selected_range())
        end, "Reset selected git hunk")

        gs_map("v", "<leader>gs", function()
          gitsigns.stage_hunk(selected_range())
        end, "Stage selected git hunk")

        gs_map({ "o", "x" }, "ih", gitsigns.select_hunk, "Git hunk")
      end,
    },
  },
}
