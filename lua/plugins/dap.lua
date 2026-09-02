-- Debug Adapter Protocol.
--
-- F-keys (same as most IDEs):
--   F5 continue/start   F9 toggle breakpoint   F10 step over
--   F11 step into       F12 step out
--
-- <leader>d* is the discoverable group in which-key.

local function mason_bin(name)
  return vim.fn.stdpath("data") .. "/mason/bin/" .. name
end

local function pick_executable()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point: ")) end, desc = "Log point" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Stop" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
      { "<leader>dR", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      {
        "<leader>dni",
        function()
          require("dap").step_over({ granularity = "instruction" })
        end,
        desc = "Step over instruction",
      },
      {
        "<leader>dsi",
        function()
          require("dap").step_into({ granularity = "instruction" })
        end,
        desc = "Step into instruction",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "python", "javadbg", "javatest" },
        automatic_installation = false,
        handlers = {},
      })

      require("nvim-dap-virtual-text").setup({ commented = true })
      dapui.setup({
        layouts = {
          {
            elements = { "scopes", "breakpoints", "stacks", "watches" },
            size = 40,
            position = "left",
          },
          {
            elements = { "repl", "console" },
            size = 0.25,
            position = "bottom",
          },
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

      -- CodeLLDB 1.11+ uses a stdio executable adapter and ships its own lldb.
      dap.adapters.codelldb = {
        type = "executable",
        command = mason_bin("codelldb"),
      }

      local lldb_config = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = pick_executable,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = lldb_config
      dap.configurations.cpp = lldb_config
      dap.configurations.rust = vim.deepcopy(lldb_config)
      local asm_dap = {
        {
          name = "Launch (GDB DAP)",
          type = "gdb",
          request = "launch",
          program = pick_executable,
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = true,
        },
      }
      dap.configurations.asm = asm_dap
      dap.configurations.nasm = asm_dap

      -- GDB 14+ native DAP: useful for x86-64 assembly and when you want GDB itself.
      -- If a session errors with TUI/layout messages, wrap `layout split` in
      -- ~/.gdbinit with: if $_gdb_setting_str("interpreter") != "dap"
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }
      dap.defaults.gdb.stepping_granularity = "instruction"

      -- Python
      local python = mason_bin("debugpy-adapter")
      if vim.fn.executable(python) == 0 then
        python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      end
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          cb({ type = "server", host = config.host or "127.0.0.1", port = config.port or 5678 })
        else
          local exe = os.getenv("VIRTUAL_ENV") and (os.getenv("VIRTUAL_ENV") .. "/bin/python") or "python3"
          cb({
            type = "executable",
            command = vim.fn.executable(mason_bin("debugpy-adapter")) == 1 and mason_bin("debugpy-adapter") or exe,
            args = vim.fn.executable(mason_bin("debugpy-adapter")) == 1 and {} or { "-m", "debugpy.adapter" },
          })
        end
      end
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return os.getenv("VIRTUAL_ENV") and (os.getenv("VIRTUAL_ENV") .. "/bin/python") or "python3"
          end,
        },
      }
    end,
  },
}
