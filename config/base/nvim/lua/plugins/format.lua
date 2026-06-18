return {
  {
    "stevearc/conform.nvim",
    event = {
      "BufWritePre",
    },
    cmd = {
      "ConformInfo",
    },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({
            async = true,
            lsp_format = "fallback",
          })
        end,
        desc = "Format file",
      },
      {
        "<leader>cf",
        function()
          local start_pos = vim.fn.getpos("'<")
          local end_pos = vim.fn.getpos("'>")
          require("conform").format({
            async = true,
            lsp_format = "fallback",
            range = {
              start = { start_pos[2], start_pos[3] },
              ["end"] = { end_pos[2], end_pos[3] },
            },
          })
        end,
        mode = "v",
        desc = "Format selection",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
        cs = { "csharpier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
    },
  },
}
