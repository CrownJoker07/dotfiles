local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyinit = lazypath .. "/lua/lazy/init.lua"

if not (vim.uv or vim.loop).fs_stat(lazyinit) then
  if (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.delete(lazypath, "rf")
  end

  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = {
    colorscheme = { "catppuccin-mocha", "habamax" },
  },
  local_spec = false,
  checker = {
    enabled = false,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
