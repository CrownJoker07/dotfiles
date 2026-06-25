local function find_project_root(file)
  local uv = vim.uv or vim.loop
  local dir = vim.fs.dirname(file)

  while dir and dir ~= "/" do
    if uv.fs_stat(dir .. "/Assets") and uv.fs_stat(dir .. "/ProjectSettings") then
      return dir
    end

    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
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

local function copy(start_line, end_line)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file path", vim.log.levels.WARN)
    return
  end

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local root = find_project_root(file)
  local rel = relative_path(root, file)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")
  local line_range = start_line == end_line and tostring(start_line) or start_line .. "-" .. end_line
  local result = string.format("@/%s:%s\n```\n%s\n```", rel, line_range, code)

  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)
  vim.notify("Copied: @/" .. rel .. ":" .. line_range)
end

vim.keymap.set("n", "<leader>yc", function()
  local line = vim.fn.line(".")
  copy(line, line)
end, { desc = "Copy AI context current line" })

vim.keymap.set("x", "<leader>yc", function()
  copy(vim.fn.line("v"), vim.fn.line("."))
end, { desc = "Copy AI context selected lines" })
