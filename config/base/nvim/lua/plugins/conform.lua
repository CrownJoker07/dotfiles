local function editorconfig_root(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return nil
  end

  return vim.fs.root(vim.fs.dirname(filename), ".editorconfig")
end

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
      formatters = {
        prettier = {
          cwd = function(_, ctx)
            return editorconfig_root(ctx.buf)
          end,
        },
        stylua = {
          cwd = function(_, ctx)
            return editorconfig_root(ctx.buf)
          end,
        },
        csharpier = {
          cwd = function(_, ctx)
            return editorconfig_root(ctx.buf)
          end,
        },
        shfmt = {
          cwd = function(_, ctx)
            return editorconfig_root(ctx.buf)
          end,
        },
      },
    },
  },
}
