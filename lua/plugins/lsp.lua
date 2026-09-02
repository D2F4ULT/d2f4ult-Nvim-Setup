-- Language servers.
--
-- Architecture (Neovim 0.11+ native LSP, see `:h lsp-config`):
--
--   nvim-lspconfig ships `lsp/<server>.lua` files describing how to start each
--   server. Neovim reads those off the runtimepath, so the plugin is a data
--   package now, not something you call `.setup()` on.
--
--   Per-server overrides live in `after/lsp/<server>.lua`. Files in `after/`
--   load last, so they win over the plugin's defaults without patching them.
--
--   `vim.lsp.enable()` then activates a server: it attaches automatically
--   based on the config's `filetypes` and `root_markers`.
--
-- To see what is actually running in a buffer: `:checkhealth vim.lsp`.

-- Servers to install through Mason and enable. Names are nvim-lspconfig names;
-- mason-lspconfig translates them to Mason package names.
local servers = {
  "clangd",        -- C / C++
  "neocmake",      -- CMake
  "asm_lsp",       -- x86-64 assembly (GAS + NASM)
  "basedpyright",  -- Python types
  "ruff",          -- Python lint + format
  "ruby_lsp",      -- Ruby / Rails
  "hls",           -- Haskell
  "lua_ls",        -- Lua
  "bashls",        -- Bash / sh
  "texlab",        -- LaTeX
  "marksman",      -- Markdown, incl. wiki-link navigation
  "ts_ls",         -- JavaScript / TypeScript
  "html",
  "cssls",
  "jsonls",
  "yamlls",
  "taplo",         -- TOML
  "dockerls",
  "sqls",          -- SQL
}

-- Handled by their own plugins rather than by plain lspconfig:
--   rust_analyzer -> rustaceanvim (lang/rust.lua)
--   jdtls         -> nvim-jdtls   (lang/java.lua)
local managed_elsewhere = { "rust_analyzer", "jdtls" }

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      ----------------------------------------------------------------------
      -- Diagnostics
      ----------------------------------------------------------------------
      vim.diagnostic.config({
        severity_sort = true,
        underline = { severity = { min = vim.diagnostic.severity.HINT } },
        update_in_insert = false,
        -- Full message on the current line only, so long errors elsewhere do
        -- not push code off the screen. `:lua vim.diagnostic.open_float()` or
        -- <leader>xd shows the rest.
        virtual_text = {
          spacing = 2,
          source = "if_many",
          current_line = true,
          severity = { min = vim.diagnostic.severity.WARN },
        },
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
      })

      ----------------------------------------------------------------------
      -- Buffer-local mappings, applied when a server attaches
      ----------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end
          local buf = ev.buf

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
          end

          -- Neovim 0.11 already provides these as defaults, so they are not
          -- redefined here -- learn them, they work in any modern Neovim:
          --   K     hover documentation      grn  rename symbol
          --   gra   code action              grr  references
          --   gri   implementations          grt  type definition
          --   gO    document symbols         <C-s> signature help (insert mode)
          --
          -- Only the genuinely missing ones are added, routed through fzf-lua
          -- so that multiple results land in a picker instead of the quickfix
          -- list by surprise.
          local ok, fzf = pcall(require, "fzf-lua")
          if ok then
            map("n", "gd", fzf.lsp_definitions, "Go to definition")
            map("n", "gD", fzf.lsp_declarations, "Go to declaration")
            map("n", "gy", fzf.lsp_typedefs, "Go to type definition")
          else
            map("n", "gd", vim.lsp.buf.definition, "Go to definition")
            map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
            map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
          end

          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>ci", "<cmd>LspInfo<cr>", "Server info")
          map("n", "<leader>cR", function()
            vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = buf }), true)
            vim.cmd("edit")
          end, "Restart servers for buffer")

          -- Inlay hints, where the server offers them. Off by default because
          -- they shift text horizontally; <leader>uh toggles per buffer.
          if client:supports_method("textDocument/inlayHint") then
            map("n", "<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
          end

          -- Highlight other references to the symbol under the cursor.
          if client:supports_method("textDocument/documentHighlight") then
            local group = vim.api.nvim_create_augroup("user_lsp_highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = group,
              buffer = buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
              group = group,
              buffer = buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      ----------------------------------------------------------------------
      -- Capabilities: advertise what blink.cmp can handle, for every server
      ----------------------------------------------------------------------
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(nil, true),
      })

      ----------------------------------------------------------------------
      -- Install and enable
      ----------------------------------------------------------------------
      require("mason-lspconfig").setup({
        ensure_installed = vim.list_extend(vim.deepcopy(servers), { "jdtls", "rust_analyzer" }),
        -- Enable explicitly below instead, so that servers owned by other
        -- plugins are never double-started.
        automatic_enable = { exclude = managed_elsewhere },
      })

      vim.lsp.enable(servers)
    end,
  },

  {
    -- Makes lua_ls understand the Neovim API and your plugins while editing
    -- this config. Replaces neodev.nvim, which is archived.
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    build = ":MasonUpdate",
  },
}
