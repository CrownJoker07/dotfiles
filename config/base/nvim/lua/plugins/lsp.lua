return {
  -- External tool manager: LSP servers, formatters, linters, DAP servers
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Mason package bootstrap
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {
        "csharpier",
        "prettier",
        "roslyn",
        "shfmt",
        "stylua",
        "tree-sitter-cli",
      },
    },
  },

  -- LSP config collection
  {
    "neovim/nvim-lspconfig",
  },

  -- C# / Roslyn LSP
  {
    "seblyng/roslyn.nvim",
    ft = {
      "cs",
      "razor",
      "cshtml",
    },
    dependencies = {
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    opts = {
      broad_search = true,
    },
    config = function(_, opts)
      vim.lsp.config("roslyn", {
        cmd = {
          "roslyn-language-server",
          "--stdio",
        },
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|formatting"] = {
            dotnet_organize_imports_on_format = true,
          },
        },
      })

      require("roslyn").setup(opts)
    end,
  },
}
