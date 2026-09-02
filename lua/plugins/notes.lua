-- Markdown / Obsidian vault.
-- Vault path is unchanged: ~/Desktop/DevLabProgig
-- render-markdown draws the buffer; obsidian.nvim handles wiki links, daily notes, search.

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cmd = "Obsidian",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "DevLabProgig",
          path = vim.fn.expand("~/Desktop/DevLabProgig/"),
        },
      },
      picker = { name = "fzf-lua" },
      -- Completion comes from the built-in obsidian-ls LSP, not blink/cmp sources.
      completion = { min_chars = 2, create_new = true },
      daily_notes = {
        folder = "Daily",
        date_format = "%Y-%m-%d",
      },
      templates = { folder = "Templates" },
      attachments = { folder = "Attachments" },
      legacy_commands = false,
      ui = { enable = false }, -- render-markdown.nvim owns rendering
      link = { style = "wiki" },
    },
    keys = {
      { "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>nf", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
      { "<leader>ns", "<cmd>Obsidian search<cr>", desc = "Search notes" },
      { "<leader>nd", "<cmd>Obsidian today<cr>", desc = "Daily note" },
      { "<leader>nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>nl", "<cmd>Obsidian links<cr>", desc = "Outgoing links" },
      { "<leader>nt", "<cmd>Obsidian tags<cr>", desc = "Tags" },
      { "<leader>no", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian app" },
      { "<leader>ni", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
      { "<leader>nT", "<cmd>Obsidian template<cr>", desc = "Insert template" },
      {
        "<leader>of",
        "<cmd>Obsidian follow_link vsplit<cr>",
        desc = "Follow wiki link in vsplit",
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    opts = {
      preset = "obsidian",
      completions = { lsp = { enabled = true } },
      file_types = { "markdown" },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.api.nvim_set_hl(0, "RenderMarkdownInlineHighlight", {
        fg = "#f6c177",
        bg = "#30303a",
      })
    end,
  },
}
