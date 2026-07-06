return {
  name = "bashls",
  config = {
    cmd = {
      "bash-language-server",
      "start",
    },
    filetypes = {
      "sh",
      "bash",
    },
    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, ".git")

      if not root then
        root = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      end

      if root then
        on_dir(root)
      end
    end,
  },
}
