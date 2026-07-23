return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = {
      "MarkdownPreview",
      "MarkdownPreviewStop",
      "MarkdownPreviewToggle",
    },
    ft = { "markdown" },
    init = function()
      vim.g.mkdp_refresh_slow = 0
    end,
    build = function(plugin)
      vim.cmd.source(vim.fs.joinpath(plugin.dir, "autoload/mkdp/util.vim"))
      vim.fn["mkdp#util#install_sync"]()
    end,
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreview<cr>",
        ft = "markdown",
        desc = "Open Markdown preview",
      },
    },
  },
}
