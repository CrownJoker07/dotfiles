local map = vim.keymap.set

local function opts(desc)
  return { desc = desc, silent = true }
end

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", opts("Save file"))
map("n", "<leader>q", "<cmd>q<CR>", opts("Quit"))

-- Vim-style window navigation
map("n", "<C-h>", "<C-w>h", opts("Go to left window"))
map("n", "<C-j>", "<C-w>j", opts("Go to lower window"))
map("n", "<C-k>", "<C-w>k", opts("Go to upper window"))
map("n", "<C-l>", "<C-w>l", opts("Go to right window"))

map("t", "<C-h>", "<C-\\><C-n><C-w>h", opts("Go to left window"))
map("t", "<C-j>", "<C-\\><C-n><C-w>j", opts("Go to lower window"))
map("t", "<C-k>", "<C-\\><C-n><C-w>k", opts("Go to upper window"))
map("t", "<C-l>", "<C-\\><C-n><C-w>l", opts("Go to right window"))

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
