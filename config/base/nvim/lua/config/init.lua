local before_plugins = {
  "options",
  "netrw",
  "keymaps",
  "autocmds",
}

for _, module in ipairs(before_plugins) do
  require("config." .. module)
end

require("config.lazy")
