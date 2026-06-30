vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

local function buffer_dir()
  local path = vim.api.nvim_buf_get_name(0)

  if path == "" then
    return vim.uv.cwd()
  end

  local stat = vim.uv.fs_stat(path)
  if stat and stat.type == "directory" then
    return path
  end

  return vim.fn.fnamemodify(path, ":p:h")
end

local function explorer_dir()
  local dir = buffer_dir()
  local result = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  local root = vim.trim(result.stdout or "")

  if result.code == 0 and root ~= "" then
    return root
  end

  return dir
end

local function path_under_dir(path, dir)
  if path == "" or dir == "" then
    return
  end

  path = vim.fs.normalize(path)
  dir = vim.fs.normalize(dir):gsub("/$", "")

  if path == dir then
    return ""
  end

  local prefix = dir .. "/"
  if vim.startswith(path, prefix) then
    return path:sub(#prefix + 1)
  end
end

local function split_path(path)
  local parts = {}

  for part in path:gmatch("[^/]+") do
    parts[#parts + 1] = part
  end

  return parts
end

local function tree_entry(line)
  local depth = 0
  local rest = vim.trim(line)

  while vim.startswith(rest, "| ") do
    depth = depth + 1
    rest = rest:sub(3)
  end

  return depth, rest
end

local function is_tree_match(entry, name, is_dir)
  if is_dir then
    return entry == name .. "/" or entry == name .. "@"
  end

  return entry == name or entry == name .. "*" or entry == name .. "@"
end

local function find_tree_line(name, is_dir, parent_line, parent_depth)
  local lines = vim.api.nvim_buf_get_lines(0, parent_line, -1, false)

  for index, line in ipairs(lines) do
    local lnum = parent_line + index
    local depth, entry = tree_entry(line)

    if depth <= parent_depth then
      break
    end

    if depth == parent_depth + 1 and is_tree_match(entry, name, is_dir) then
      return lnum
    end
  end
end

local function find_root_line(root)
  local root_name = vim.fn.fnamemodify(root, ":t")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for index, line in ipairs(lines) do
    local depth, entry = tree_entry(line)

    if depth == 0 and is_tree_match(entry, root_name, true) then
      return index
    end
  end
end

local function reveal_in_tree(root, target)
  local relative = path_under_dir(target, root)
  if not relative or relative == "" then
    return
  end

  local parts = split_path(relative)
  if #parts == 0 then
    return
  end

  local dirs = vim.list_slice(parts, 1, #parts - 1)
  local filename = parts[#parts]

  local function step(parent_line, parent_depth, dir_index)
    if vim.bo.filetype ~= "netrw" then
      return
    end

    if dir_index > #dirs then
      local file_line = find_tree_line(filename, false, parent_line, parent_depth)
      if file_line then
        vim.api.nvim_win_set_cursor(0, { file_line, 0 })
      end

      return
    end

    local dir_line = find_tree_line(dirs[dir_index], true, parent_line, parent_depth)
    if not dir_line then
      return
    end

    local next_name = dirs[dir_index + 1] or filename
    local next_is_dir = dir_index < #dirs

    if find_tree_line(next_name, next_is_dir, dir_line, parent_depth + 1) then
      step(dir_line, parent_depth + 1, dir_index + 1)
      return
    end

    vim.api.nvim_win_set_cursor(0, { dir_line, 0 })
    vim.api.nvim_feedkeys(vim.keycode("<CR>"), "mx", false)
    vim.defer_fn(function()
      step(dir_line, parent_depth + 1, dir_index + 1)
    end, 20)
  end

  vim.schedule(function()
    local root_line = find_root_line(root)
    if root_line then
      step(root_line, 0, 1)
    end
  end)
end

local function alternate_buffer()
  local bufnr = vim.fn.bufnr("#")

  if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
    return bufnr
  end
end

local function return_buffer()
  local bufnr = vim.g.netrw_return_bufnr

  if
    type(bufnr) == "number"
    and bufnr > 0
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
  then
    return bufnr
  end

  return alternate_buffer()
end

local function return_from_explorer()
  local bufnr = return_buffer()

  if bufnr then
    vim.cmd.buffer(bufnr)
    return
  end

  local path = vim.g.netrw_return_path
  if type(path) == "string" and path ~= "" then
    vim.cmd.edit(vim.fn.fnameescape(path))
    return
  end

  vim.cmd.enew()
end

vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "netrw" then
    return_from_explorer()
    return
  end

  local target = vim.api.nvim_buf_get_name(0)
  vim.g.netrw_return_bufnr = vim.api.nvim_get_current_buf()
  vim.g.netrw_return_path = target

  local dir = explorer_dir()
  vim.cmd("Ntree " .. vim.fn.fnameescape(dir))
  reveal_in_tree(dir, target)
end, { desc = "Explore project tree", silent = true })
