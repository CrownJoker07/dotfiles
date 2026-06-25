return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      if #vim.api.nvim_list_uis() > 0 then
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
      end

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
