return {
  name = "pyright",
  config = {
    cmd = {
      "pyright-langserver",
      "--stdio",
    },
    filetypes = {
      "python",
    },
    root_markers = {
      "pyrightconfig.json",
      "pyproject.toml",
      ".git",
    },
  },
}
