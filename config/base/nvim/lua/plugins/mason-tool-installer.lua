return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = function()
      return {
        run_on_start = #vim.api.nvim_list_uis() > 0,
        start_delay = 3000,
        debounce_hours = 5,
        ensure_installed = {
          "csharpier",
          "prettier",
          "roslyn-language-server",
          "shfmt",
          "stylua",
          "tree-sitter-cli",
        },
      }
    end,
  },
}
