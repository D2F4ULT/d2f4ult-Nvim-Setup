-- Treesitter.
--
-- This is the `main` branch rewrite, which is a different plugin from the old
-- `master` branch: `setup()` only takes `install_dir`, nothing is enabled
-- automatically, and parsers are installed with `install()`. Highlighting is
-- turned on per buffer with `vim.treesitter.start()`.
--
-- Requires the tree-sitter CLI (>= 0.26.1) on PATH: `pacman -S tree-sitter-cli`.

-- Parsers, grouped so it is obvious why each one is here.
local parsers = {
  -- Systems / low level
  "c", "cpp", "asm", "nasm", "objdump", "linkerscript", "make", "cmake", "ninja", "meson",
  -- Everyday languages
  "python", "rust", "ruby", "haskell", "java", "lua", "luadoc", "luap",
  -- Web
  "javascript", "typescript", "tsx", "html", "css", "scss", "jsdoc",
  -- Data / config
  "json", "yaml", "toml", "xml", "sql", "csv", "ssh_config",
  -- Shell
  "bash", "fish", "awk",
  -- Docs and prose
  "markdown", "markdown_inline", "latex", "bibtex", "typst",
  -- Git
  "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore", "diff",
  -- Tooling
  "dockerfile", "just", "requirements",
  -- Neovim itself
  "vim", "vimdoc", "query", "regex", "printf", "comment",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- The rewrite explicitly does not support lazy-loading.
    lazy = false,
    build = ":TSUpdate",
    keys = {
      { "<leader>ui", vim.show_pos, desc = "Inspect treesitter node under cursor" },
      { "<leader>uI", "<cmd>InspectTree<cr>", desc = "Show treesitter tree" },
    },
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

      -- Async; a no-op for parsers that are already present.
      ts.install(parsers)

      -- Enable highlighting for any filetype that has a parser available,
      -- rather than maintaining a second list that has to be kept in sync.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          if vim.b[ev.buf].big_file then return end

          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then return end

          -- Folds follow the syntax tree. Everything starts unfolded
          -- (foldlevel=99); zc closes one, zR opens all, za toggles.
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

          -- Indentation is deliberately left to Neovim's built-in indent
          -- plugins, which are more reliable for C, C++, Java and Python than
          -- treesitter's (still experimental) indentexpr. To try the
          -- treesitter one in a buffer:
          --   :setlocal indentexpr=v:lua.require'nvim-treesitter'.indentexpr()
        end,
      })
    end,
  },

  {
    -- Syntax-aware text objects. These compose with every operator, so `daf`
    -- deletes a function, `cif` changes its body, `yaa` yanks an argument.
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local map = vim.keymap.set

      -- a = "around" (includes the signature/braces), i = "inner" (just the body)
      local objects = {
        f = { "@function.outer", "@function.inner", "function" },
        c = { "@class.outer", "@class.inner", "class" },
        a = { "@parameter.outer", "@parameter.inner", "argument" },
        o = { "@loop.outer", "@loop.inner", "loop" },
        i = { "@conditional.outer", "@conditional.inner", "conditional" },
        ["/"] = { "@comment.outer", "@comment.inner", "comment" },
        b = { "@block.outer", "@block.inner", "block" },
      }

      for key, spec in pairs(objects) do
        local outer, inner, name = spec[1], spec[2], spec[3]
        map({ "x", "o" }, "a" .. key, function()
          select.select_textobject(outer, "textobjects")
        end, { desc = "around " .. name })
        map({ "x", "o" }, "i" .. key, function()
          select.select_textobject(inner, "textobjects")
        end, { desc = "inner " .. name })
      end

      -- Jump between definitions. ]m/[m mirror Vim's built-in method motions.
      local jumps = {
        ["]m"] = { move.goto_next_start, "@function.outer", "Next function start" },
        ["[m"] = { move.goto_previous_start, "@function.outer", "Previous function start" },
        ["]M"] = { move.goto_next_end, "@function.outer", "Next function end" },
        ["[M"] = { move.goto_previous_end, "@function.outer", "Previous function end" },
        ["]]"] = { move.goto_next_start, "@class.outer", "Next class start" },
        ["[["] = { move.goto_previous_start, "@class.outer", "Previous class start" },
        ["]a"] = { move.goto_next_start, "@parameter.inner", "Next argument" },
        ["[a"] = { move.goto_previous_start, "@parameter.inner", "Previous argument" },
      }

      for lhs, spec in pairs(jumps) do
        local fn, query, desc = spec[1], spec[2], spec[3]
        map({ "n", "x", "o" }, lhs, function() fn(query, "textobjects") end, { desc = desc })
      end

      -- Swap arguments without retyping them: useful for reordering parameters.
      local swap = require("nvim-treesitter-textobjects.swap")
      map("n", "<leader>cs", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap argument with next" })
      map("n", "<leader>cS", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap argument with previous" })
    end,
  },
}
