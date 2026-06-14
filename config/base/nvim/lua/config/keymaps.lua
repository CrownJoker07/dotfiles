-- KEYMAPS
local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Vim-style window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to lower window" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to upper window" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window" })

-- Open lazygit
map("n", "<leader>gg", function()
  vim.cmd("tabnew")
  vim.cmd("terminal lazygit")
  vim.cmd("startinsert")
end, { desc = "Open Lazygit" })

-- Open git remote repository
map("n", "<leader>go", function()
  local url = vim.fn.system("git remote get-url origin"):gsub("%s+", "")
  if url == "" or vim.v.shell_error ~= 0 then
    vim.notify("No git remote found", vim.log.levels.ERROR)
    return
  end
  url = url:gsub("^git@([^:]+):", "https://%1/"):gsub("%.git$", "")
  vim.ui.open(url)
end, { desc = "Open Git remote repository" })

-- Open image with system viewer
map("n", "<leader>oi", function()
  vim.fn.jobstart({ "xdg-open", vim.fn.expand("%:p") }, { detach = true })
end, { desc = "Open image with system viewer" })
