local tools = {
  "clangd",
  "csharpier",
  "prettier",
  "roslyn-language-server",
  "shfmt",
  "stylua",
  "tree-sitter-cli",
}

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = function()
      return {
        -- Avoid automatic installs in headless checks; manual commands still work.
        run_on_start = #vim.api.nvim_list_uis() > 0,
        start_delay = 3000,
        debounce_hours = 5,
        ensure_installed = tools,
        integrations = {
          ["mason-lspconfig"] = false,
          ["mason-null-ls"] = false,
          ["mason-nvim-dap"] = false,
        },
      }
    end,
  },
}
