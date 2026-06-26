local function format()
  -- In visual mode, conform.nvim automatically uses the selected range. If a
  -- formatter does not support native range formatting, conform applies a
  -- best-effort range diff instead of requiring custom range_args checks here.
  require("conform").format({
    async = true,
    lsp_format = "fallback",
  })
end

return {
  {
    "stevearc/conform.nvim",
    cmd = {
      "ConformInfo",
    },
    keys = {
      {
        "<leader>cf",
        format,
        mode = { "n", "v" },
        desc = "Format file or selection",
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
