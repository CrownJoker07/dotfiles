local before_plugins = {
  "options",
  "highlights",
  "netrw",
  "keymaps",
  "autocmds",
  "lsp",
}

for _, module in ipairs(before_plugins) do
  require("config." .. module)
end

require("config.lazy")
