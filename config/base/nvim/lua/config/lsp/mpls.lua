return {
  name = "mpls",
  config = {
    cmd = {
      vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "mpls"),
      "--no-auto",
      "--tabs",
      "--theme",
      "dark",
    },
    filetypes = {
      "markdown",
    },
    root_markers = {
      ".marksman.toml",
      ".git",
    },
    on_attach = function(client, bufnr)
      vim.keymap.set("n", "<leader>mp", function()
        client:exec_cmd({
          title = "Preview Markdown with mpls",
          command = "open-preview",
        })
      end, {
        buffer = bufnr,
        desc = "Open Markdown preview",
      })
    end,
  },
}
