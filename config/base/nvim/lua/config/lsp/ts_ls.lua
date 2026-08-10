return {
  name = "ts_ls",
  config = {
    cmd = {
      "typescript-language-server",
      "--stdio",
    },
    cmd_env = {
      NODE_OPTIONS = "--max-old-space-size=8192",
    },
    filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    root_markers = {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
      ".git",
    },
  },
}
