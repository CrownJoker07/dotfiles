return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "mason-org/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      if vim.fn.isdirectory(mason_bin) == 1 then
        vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
      end

      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      if vim.fn.executable("tree-sitter") ~= 1 then
        vim.schedule(function()
          vim.notify("tree-sitter CLI is managed by Mason; restart Neovim after Mason installs it.", vim.log.levels.WARN)
        end)
        return
      end

      -- Parser names
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

      -- Filetype names
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
