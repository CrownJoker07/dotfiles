return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = {
      "MarkdownPreview",
      "MarkdownPreviewStop",
      "MarkdownPreviewToggle",
    },
    ft = { "markdown" },
    build = function(plugin)
      vim.cmd.source(vim.fs.joinpath(plugin.dir, "autoload/mkdp/util.vim"))
      vim.fn["mkdp#util#install_sync"]()
    end,
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreviewToggle<cr>",
        ft = "markdown",
        desc = "Toggle Markdown preview",
      },
    },
  },
}
