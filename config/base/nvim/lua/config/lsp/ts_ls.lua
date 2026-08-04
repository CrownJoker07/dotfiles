return {
  name = "ts_ls",
  config = {
    cmd = {
      "typescript-language-server",
      "--stdio",
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
