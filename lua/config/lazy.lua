-- lazy.nvim bootstrap and configuration.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true, notify = false, frequency = 86400 },
  change_detection = { enabled = true, notify = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      -- Runtime plugins we never use. Each one skipped is one less directory
      -- Neovim scans on every startup. matchit stays: it is what extends % to
      -- jump between if/endif, opening/closing tags and similar pairs.
      disabled_plugins = {
        "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor", "rplugin",
      },
    },
  },
})

vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<cr>", { desc = "Lazy (plugin manager)" })
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Mason (LSP/DAP/tool installer)" })
vim.keymap.set("n", "<leader>ps", "<cmd>Lazy profile<cr>", { desc = "Startup profile" })
vim.keymap.set("n", "<leader>ph", "<cmd>checkhealth<cr>", { desc = "Check health" })
