-- Terminal: snacks.nvim split/float, plus compile/run helper.

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>tt",
        function()
          Snacks.terminal.toggle(nil, { win = { position = "float" } })
        end,
        desc = "Toggle floating terminal",
      },
      {
        "<leader>tb",
        function()
          Snacks.terminal.toggle(nil, {
            cwd = vim.fn.expand("%:p:h"),
            win = { position = "bottom", height = 0.3 },
          })
        end,
        desc = "Toggle bottom terminal (file dir)",
      },
      {
        "<c-\\>",
        function()
          Snacks.terminal.toggle()
        end,
        mode = { "n", "t" },
        desc = "Toggle terminal",
      },
      {
        "<leader>rr",
        function()
          require("config.run").compile_run()
        end,
        desc = "Compile and run current file",
      },
    },
  },
}
