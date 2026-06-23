return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "mason-org/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      require("nvim-treesitter").install({
        "c_sharp",
        "lua",
        "vim",
        "vimdoc",
        "json",
        "bash",
        "markdown",
        "markdown_inline",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "cs",
          "lua",
          "vim",
          "help",
          "json",
          "bash",
          "sh",
          "markdown",
        },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
