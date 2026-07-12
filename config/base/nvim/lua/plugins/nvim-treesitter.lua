local parsers = {
  "bash",
  "c_sharp",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "vim",
  "vimdoc",
}

local filetypes = {
  "bash",
  "cs",
  "help",
  "json",
  "lua",
  "markdown",
  "sh",
  "vim",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      if #vim.api.nvim_list_uis() > 0 then
        if vim.fn.executable("tree-sitter") == 1 then
          require("nvim-treesitter").install(parsers)
        else
          vim.api.nvim_create_autocmd("User", {
            pattern = "MasonToolsUpdateCompleted",
            once = true,
            callback = function()
              if vim.fn.executable("tree-sitter") == 1 then
                require("nvim-treesitter").install(parsers)
              end
            end,
          })
        end
      end

      -- Parser names can differ from filetypes, e.g. c_sharp -> cs and vimdoc -> help.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
