local feature_dir = vim.fn.stdpath("config") .. "/lua/features"
local modules = {}

for name in vim.fs.dir(feature_dir) do
  local module = name:match("^(.*)%.lua$")
  if module and module ~= "init" then
    modules[#modules + 1] = module
  end
end

table.sort(modules)

for _, module in ipairs(modules) do
  require("features." .. module)
end
