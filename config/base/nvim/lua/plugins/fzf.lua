return {
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Find buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>fh", "<cmd>FzfLua helptags<CR>", desc = "Help tags" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
    },
    opts = {
      fzf_colors = true,
      winopts = {
        fullscreen = true,
        preview = {
          hidden = true,
        },
      },
      defaults = {
        formatter = "path.filename_first",
      },
    },
  },
}
