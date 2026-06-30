local servers = {
  "clangd",
  "roslyn",
}

for _, server in ipairs(servers) do
  local spec = require("config.lsp." .. server)

  vim.lsp.config(spec.name, spec.config)
  vim.lsp.enable(spec.name)
end
