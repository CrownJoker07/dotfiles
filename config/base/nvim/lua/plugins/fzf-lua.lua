return {
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "FzfLua",
    keys = {
      {
        "<leader>ff",
        function()
          -- File search is usually faster without a preview window.
          require("fzf-lua").files({ previewer = false })
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fh",
        function()
          require("fzf-lua").helptags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>cs",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>fs",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>fS",
        function()
          require("fzf-lua").lsp_workspace_symbols()
        end,
        desc = "Workspace symbols",
      },
    },
    opts = {
      fzf_colors = true,
      winopts = {
        fullscreen = true,
        preview = {
          horizontal = "right:40%",
          vertical = "down:35%",
        },
      },
      defaults = {
        formatter = "path.filename_first",
      },
    },
  },
}
