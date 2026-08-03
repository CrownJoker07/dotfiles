local servers = {
  "bashls",
  "clangd",
  "roslyn",
  "rust_analyzer",
}

local M = {}
local restart_patterns = {}
local snapshots = {}

local function snapshot(client)
  local files = {}

  for entry, type in vim.fs.dir(client.root_dir) do
    if type == "file" and vim.iter(restart_patterns[client.name]):any(function(pattern)
      return entry:match(pattern) ~= nil
    end) then
      local path = vim.fs.joinpath(client.root_dir, entry)
      local stat = vim.uv.fs_stat(path)
      files[path] = stat and table.concat({ stat.mtime.sec, stat.mtime.nsec, stat.size }, ":") or nil
    end
  end

  return files
end

function M.track(client)
  if restart_patterns[client.name] and client.root_dir then
    snapshots[client.name .. "\0" .. client.root_dir] = snapshot(client)
  end
end

function M.check()
  local restart = {}

  for _, client in ipairs(vim.lsp.get_clients()) do
    local key = client.name .. "\0" .. (client.root_dir or "")
    if snapshots[key] then
      local current = snapshot(client)
      if not vim.deep_equal(current, snapshots[key]) then
        restart[client.name] = true
      end
      snapshots[key] = current
    end
  end

  for name in pairs(restart) do
    local server = name
    vim.lsp.enable(server, false)
    vim.schedule(function()
      vim.lsp.enable(server)
      vim.notify("Restarted " .. server .. " after project files changed", vim.log.levels.INFO)
    end)
  end
end

for _, server in ipairs(servers) do
  local spec = require("config.lsp." .. server)

  vim.lsp.config(spec.name, spec.config)
  if spec.restart_files then
    restart_patterns[spec.name] = spec.restart_files
  end
  vim.lsp.enable(spec.name)
end

return M
