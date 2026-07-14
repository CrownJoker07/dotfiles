local function no_preview()
  return { previewer = false }
end

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
          require("fzf-lua").files(no_preview())
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("fzf-lua").live_grep({ previewer = false, hidden = true })
        end,
        desc = "Live grep",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers(no_preview())
        end,
        desc = "Find buffers",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").oldfiles(no_preview())
        end,
        desc = "Recent files",
      },
      {
        "<leader>fh",
        function()
          require("fzf-lua").helptags(no_preview())
        end,
        desc = "Help tags",
      },
      {
        "<leader>fs",
        function()
          require("fzf-lua").lsp_document_symbols(no_preview())
        end,
        desc = "Document symbols",
      },
      {
        "<leader>fS",
        function()
          require("fzf-lua").lsp_workspace_symbols(no_preview())
        end,
        desc = "Workspace symbols",
      },
    },
    opts = {
      fzf_colors = true,
      winopts = {
        fullscreen = true,
      },
      defaults = {
        formatter = "path.filename_first",
      },
    },
  },
}
