local function explorer_dir()
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

local function alternate_buffer()
  local bufnr = vim.fn.bufnr("#")

  if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
    return bufnr
  end
end

vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "netrw" then
    local bufnr = alternate_buffer()

    if bufnr then
      vim.cmd.buffer(bufnr)
    else
      vim.cmd.enew()
    end

    return
  end

  local dir = explorer_dir()
  vim.cmd("Explore " .. vim.fn.fnameescape(dir))
end, { desc = "Explore current directory", silent = true })
