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
opt.completeopt = {
  "menuone",
  "noselect",
  "popup",
}

-- Neovim currently defaults 'autoread' to true, but keep it explicit because
-- external edits from AI/tools rely on the checktime autocmds in autocmds.lua.
opt.autoread = true
opt.termguicolors = true
opt.signcolumn = "yes"
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
