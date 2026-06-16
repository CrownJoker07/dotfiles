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

-- Copy code with file path and line numbers for AI context
local function find_project_root(file)
  local uv = vim.uv or vim.loop
  local dir = vim.fs.dirname(file)
  while dir and dir ~= "/" do
    if uv.fs_stat(dir .. "/Assets") and uv.fs_stat(dir .. "/ProjectSettings") then
      return dir
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then break end
    dir = parent
  end
  return vim.fs.root(file, ".git") or vim.fn.getcwd()
end

local function relative_path(root, file)
  root = vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
  file = vim.fn.fnamemodify(file, ":p")
  if file:sub(1, #root + 1) == root .. "/" then
    return file:sub(#root + 2):gsub("\\", "/")
  end
  return vim.fn.fnamemodify(file, ":t"):gsub("\\", "/")
end

local function copy_ai_context(start_line, end_line)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file path", vim.log.levels.WARN)
    return
  end
  if start_line > end_line then start_line, end_line = end_line, start_line end

  local root = find_project_root(file)
  local rel = relative_path(root, file)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local width = #tostring(end_line)
  for i, line in ipairs(lines) do
    lines[i] = string.format("%" .. width .. "d | %s", start_line + i - 1, line)
  end
  local code = table.concat(lines, "\n")
  local line_range = start_line == end_line and tostring(start_line) or start_line .. "-" .. end_line
  local result = string.format("@/%s:%s\n```\n%s\n```", rel, line_range, code)

  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)
  vim.notify("Copied: @/" .. rel .. ":" .. line_range)
end

map("n", "<leader>yc", function()
  local line = vim.fn.line(".")
  copy_ai_context(line, line)
end, { desc = "Copy AI context current line" })

map("x", "<leader>yc", function()
  copy_ai_context(vim.fn.line("v"), vim.fn.line("."))
end, { desc = "Copy AI context selected lines" })
