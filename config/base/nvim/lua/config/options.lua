local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true
opt.scrolloff = 10
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

opt.confirm = true

-- Used with the checktime autocmds to reload files changed by external tools.
opt.autoread = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.showmode = false
opt.undofile = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

opt.splitright = true
opt.splitbelow = true

opt.updatetime = 250
opt.timeoutlen = 500

-- Delay clipboard setup to avoid slowing down startup while provider detection runs.
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)
