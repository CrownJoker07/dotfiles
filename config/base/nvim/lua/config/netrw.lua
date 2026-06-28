vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_keepdir = 0
vim.g.netrw_list_hide = [[^\./$,^\../$,^\.git/$]]
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 28

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

vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd("silent! close")
    return
  end

  local dir = explorer_dir()
  vim.cmd("silent! Lexplore " .. vim.fn.fnameescape(dir))
end, { desc = "Explorer: Toggle current directory", silent = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  desc = "Use file-manager style netrw mappings",
  callback = function(event)
    local opts = { buffer = event.buf, remap = true, silent = true }

    vim.keymap.set("n", "h", "-", vim.tbl_extend("force", opts, { desc = "netrw: Parent directory" }))
    vim.keymap.set("n", "l", "<CR>", vim.tbl_extend("force", opts, { desc = "netrw: Open" }))
    vim.keymap.set("n", "L", "v", vim.tbl_extend("force", opts, { desc = "netrw: Open vertical split" }))
  end,
})
