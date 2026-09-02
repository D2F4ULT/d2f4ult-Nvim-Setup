-- Neovim entry point.
--
-- Layout:
--   lua/config/    editor settings, keymaps, autocommands, lazy.nvim bootstrap
--   lua/plugins/   one file per concern, each returning a lazy.nvim spec
--   lua/util/      small helpers shared between modules
--   after/lsp/     one file per language server (see `:h lsp-config`)
--   ftplugin/      per-filetype settings

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
