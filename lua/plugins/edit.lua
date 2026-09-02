-- Editing helpers. Native `gc`/`gcc` (Neovim 0.10+) handles comments.

return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  {
    -- Bracket pairing only. Do NOT hook nvim-cmp confirm events — blink.cmp
    -- inserts brackets itself via completion.accept.auto_brackets.
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      fast_wrap = {},
      -- Keep <CR> for indent-inside-brackets, but it must never try to confirm
      -- a completion menu (blink does not use pumvisible()).
      map_cr = true,
      map_bs = true,
      enable_check_bracket_line = false,
    },
  },
}
