return {
  name = "ts_ls",
  config = {
    cmd = {
      "typescript-language-server",
      "--stdio",
    },
    init_options = {
      maxTsServerMemory = 12288,
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
