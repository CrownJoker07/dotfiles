vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leader key must be set before plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic config
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
