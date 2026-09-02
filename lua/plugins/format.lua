-- Formatting with conform.nvim.
-- Format-on-save is on, but a buffer can opt out with `:FormatDisable`.

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "Format", "FormatDisable", "FormatEnable" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        if vim.b[bufnr].big_file then
          return
        end
        return { timeout_ms = 1500, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        java = { "google-java-format" },
        rust = { "rustfmt" },
        ruby = { "rubocop" },
        haskell = { "fourmolu" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        toml = { "taplo" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        cmake = { "cmake_format" },
        tex = { "latexindent" },
        bib = { "bibtex-tidy" },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      vim.api.nvim_create_user_command("Format", function(args)
        require("conform").format({ async = true, lsp_format = "fallback", range = args.range ~= 0 and {
          start = { args.line1, 0 },
          ["end"] = { args.line2, 0 },
        } or nil })
      end, { range = true, desc = "Format buffer or range" })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { bang = true, desc = "Disable format-on-save (! = this buffer)" })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable format-on-save" })
    end,
  },

  {
    -- Extra Mason packages that are not language servers.
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "clang-format",
        "google-java-format",
        "prettier",
        "shfmt",
        "fourmolu",
        "latexindent",
        "codelldb",
        "debugpy",
        "java-debug-adapter",
        "java-test",
      },
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 24,
    },
  },
}
