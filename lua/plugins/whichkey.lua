-- which-key: shows what can follow the key you just pressed.
--
-- The `add()` list format below is the v3 API. The old nested-table
-- `register()` form is deprecated and silently drops mappings.
--
-- Beyond labelling leader groups, this also documents the *built-in* Vim keys
-- (marks, registers, folds, the jumplist), which is where most of the speed
-- actually comes from. Press <leader> and pause, or hit <C-w> or `z` or `g`
-- and pause, to browse them.

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer-local keymaps",
    },
  },
  opts = {
    preset = "helix",
    delay = function(ctx) return ctx.plugin and 0 or 300 end,
    icons = { mappings = false },
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code / LSP" },
      { "<leader>d", group = "debug" },
      { "<leader>f", group = "find files" },
      { "<leader>g", group = "git" },
      { "<leader>h", group = "git hunks" },
      { "<leader>n", group = "notes" },
      { "<leader>p", group = "plugins & tools" },
      { "<leader>q", group = "session" },
      { "<leader>r", group = "run / build / test" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "terminal" },
      { "<leader>u", group = "toggle" },
      { "<leader>x", group = "diagnostics & lists" },

      { "[", group = "previous" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "z", group = "fold / scroll / spell" },

      -- Window commands. Document each direction separately — a single
      -- "<C-w>hjkl" entry is wrong and can confuse which-key's prefix tree.
      { "<C-w>", group = "window" },
      { "<C-w>h", desc = "Go to left window" },
      { "<C-w>j", desc = "Go to window below" },
      { "<C-w>k", desc = "Go to window above" },
      { "<C-w>l", desc = "Go to right window" },
      { "<C-w>H", desc = "Move window far left" },
      { "<C-w>J", desc = "Move window far bottom" },
      { "<C-w>K", desc = "Move window far top" },
      { "<C-w>L", desc = "Move window far right" },
      { "<C-w>s", desc = "Split horizontally" },
      { "<C-w>v", desc = "Split vertically" },
      { "<C-w>c", desc = "Close window" },
      { "<C-w>o", desc = "Close all other windows" },
      { "<C-w>=", desc = "Equalise window sizes" },
      { "<C-w>T", desc = "Break window out into a new tab" },
      { "<C-h>", desc = "Go to left window" },
      { "<C-j>", desc = "Go to window below" },
      { "<C-k>", desc = "Go to window above" },
      { "<C-l>", desc = "Go to right window" },

      { '"', group = "register" },
      { "'", group = "jump to mark (line)" },
      { "`", group = "jump to mark (exact position)" },
      { "m", group = "set mark" },
    },
  },
}
