local map = vim.keymap.set

local function opts(desc)
  return { desc = desc, silent = true }
end

local function accept_completion_or(keys)
  if vim.fn.pumvisible() == 0 then
    return keys
  end

  if vim.fn.complete_info({ "selected" }).selected == -1 then
    return "<C-n><C-y>"
  end

  return "<C-y>"
end

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", opts("Save file"))
map("n", "<leader>q", "<cmd>q<CR>", opts("Quit"))

-- Completion
map("i", "<Tab>", function()
  return accept_completion_or("<Tab>")
end, { desc = "Accept completion", expr = true })

map("i", "<CR>", function()
  return accept_completion_or("<CR>")
end, { desc = "Accept completion", expr = true })

map("i", "<C-Space>", function()
  if vim.lsp.completion then
    vim.lsp.completion.get()
  end
end, opts("Trigger LSP completion"))

-- Open lazygit
map("n", "<leader>gg", function()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed", vim.log.levels.ERROR)
    return
  end

  vim.cmd("tabnew")
  vim.cmd("terminal lazygit")
  vim.cmd("startinsert")
end, opts("Open Lazygit"))

-- Open git remote repository
map("n", "<leader>go", function()
  local result = vim.system({ "git", "remote", "get-url", "origin" }, { text = true }):wait()
  local url = vim.trim(result.stdout or "")

  if result.code ~= 0 or url == "" then
    vim.notify("No git remote found", vim.log.levels.ERROR)
    return
  end

  -- Convert common SSH remote forms to browser-friendly HTTPS URLs.
  url = url:gsub("^git@([^:]+):", "https://%1/")
  url = url:gsub("^ssh://git@([^/]+)/", "https://%1/")
  url = url:gsub("%.git$", "")

  vim.ui.open(url)
end, opts("Open Git remote repository"))

-- Open current file with system viewer
map("n", "<leader>oi", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("Current buffer has no file", vim.log.levels.ERROR)
    return
  end

  vim.ui.open(path)
end, opts("Open current file with system viewer"))
