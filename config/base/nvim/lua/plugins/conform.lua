local function format()
  local conform = require("conform")
  local mode = vim.api.nvim_get_mode().mode

  if mode == "n" then
    conform.format({
      async = true,
      lsp_format = "fallback",
    })
    return
  end

  if mode ~= "v" and mode ~= "V" then
    vim.notify("Blockwise range formatting is not supported", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local formatters = conform.list_formatters(bufnr)
  local has_formatters = #formatters > 0
  local all_support_range = has_formatters

  for _, formatter in ipairs(formatters) do
    local config = conform.get_formatter_config(formatter.name, bufnr)
    if not config or not config.range_args then
      all_support_range = false
      break
    end
  end

  if all_support_range then
    conform.format({
      async = true,
      lsp_format = "never",
    })
    return
  end

  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    method = "textDocument/rangeFormatting",
  })

  if #clients > 0 then
    vim.lsp.buf.format({
      async = true,
      bufnr = bufnr,
      id = clients[1].id,
    })
    return
  end

  vim.notify("No formatter supports reliable range formatting for this buffer", vim.log.levels.WARN)
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
