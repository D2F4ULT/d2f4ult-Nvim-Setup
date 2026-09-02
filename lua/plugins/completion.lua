-- Completion: blink.cmp.
--
-- Keys follow Vim's insert-completion conventions:
--
--   <C-n> / <C-p>   next / previous item
--   <CR> / <C-y>    accept selected item (or first item if none selected)
--   <C-e>           dismiss
--   <C-space>       open menu / toggle documentation
--   <Tab> / <S-Tab> snippet placeholders only
--
-- <CR> accepts only while the menu is open; otherwise it falls through to
-- nvim-autopairs / a normal newline.
--
-- IMPORTANT: do not lazy-load on InsertEnter alone. blink applies buffer-local
-- keymaps from an InsertEnter autocmd registered during setup; if the plugin
-- itself only loads on that same event, the first insert session can miss the
-- maps and <C-y> silently falls through to Vim's "copy character from above".

return {
  {
    "saghen/blink.cmp",
    -- Load before the first InsertEnter so keymap autocmds are registered.
    event = "VeryLazy",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_lua").lazy_load({
            paths = vim.fn.stdpath("config") .. "/snippets",
          })
        end,
      },
    },
    opts = {
      snippets = { preset = "luasnip" },

      keymap = {
        preset = "default",
        -- Accept when the menu is open (including with nothing preselected);
        -- otherwise fall through so autopairs can handle indent-inside-brackets.
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<C-y>"] = {
          function(cmp)
            return cmp.select_and_accept({ force = true })
          end,
          "fallback",
        },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },

      appearance = {
        nerd_font_variant = "mono",
        use_nvim_cmp_as_default = false,
      },

      completion = {
        list = {
          selection = { preselect = false, auto_insert = false },
        },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = false },
        accept = { auto_brackets = { enabled = true } },
      },

      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          buffer = {
            opts = {
              get_bufnrs = function()
                return vim.tbl_filter(function(b)
                  return vim.bo[b].buftype == ""
                end, vim.api.nvim_list_bufs())
              end,
            },
          },
          path = {
            opts = {
              get_cwd = function(ctx)
                return vim.fn.expand(("#%d:p:h"):format(ctx.bufnr))
              end,
            },
          },
          lsp = { fallbacks = { "buffer" } },
        },
      },

      -- Insert mode only. Native cmdline completion (`:`, `/`, `?`) stays Vim's.
      cmdline = { enabled = false },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
        sorts = { "exact", "score", "sort_text" },
      },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
      require("blink.cmp").setup(opts)

      -- If the user is already typing when setup finishes, attach maps now.
      if vim.api.nvim_get_mode().mode:match("^[iR]") then
        local mappings = require("blink.cmp.keymap").get_mappings(opts.keymap, "default")
        require("blink.cmp.keymap.apply").keymap_to_current_buffer(mappings)
      end
    end,
  },
}
