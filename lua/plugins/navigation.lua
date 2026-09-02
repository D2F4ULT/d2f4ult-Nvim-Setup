-- Finding things: fzf-lua, Neo-tree sidebar, Oil for buffer-dir editing.
--
-- fzf-lua drives the real `fzf` binary for project-wide find/grep.
-- Neo-tree is the persistent left project tree (<leader>e).
-- Oil stays available on `-` for Vim-style directory buffer editing.

return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-mini/mini.icons" },
    keys = {
      { "<leader><space>", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Grep project" },
      { "<leader>,", "<cmd>FzfLua buffers<cr>", desc = "Switch buffer" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command history" },

      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Git-tracked files" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      {
        "<leader>fc",
        function()
          require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Neovim config files",
      },

      { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep project" },
      { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
      { "<leader>sw", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Grep selection" },
      { "<leader>sb", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Grep current buffer" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
      { "<leader>sh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
      { "<leader>sm", "<cmd>FzfLua manpages<cr>", desc = "Man pages" },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
      { "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>s/", "<cmd>FzfLua search_history<cr>", desc = "Search history" },
      { "<leader>sM", "<cmd>FzfLua marks<cr>", desc = "Marks" },
      { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
      { "<leader>sr", "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>su", "<cmd>FzfLua undotree<cr>", desc = "Undo tree" },
      { "<leader>st", "<cmd>FzfLua treesitter<cr>", desc = "Symbols in buffer (treesitter)" },
      { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix list" },
      { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location list" },
      { "<leader>sC", "<cmd>FzfLua colorschemes<cr>", desc = "Colorschemes" },

      { "<leader>cd", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>cw", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>cf", "<cmd>FzfLua lsp_finder<cr>", desc = "All references/definitions" },
      { "<leader>cc", "<cmd>FzfLua lsp_incoming_calls<cr>", desc = "Incoming calls" },
      { "<leader>cC", "<cmd>FzfLua lsp_outgoing_calls<cr>", desc = "Outgoing calls" },

      { "<leader>xx", "<cmd>FzfLua diagnostics_document<cr>", desc = "Buffer diagnostics" },
      { "<leader>xX", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Project diagnostics" },

      { "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
      { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits (project)" },
      { "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", desc = "Commits (this file)" },
      { "<leader>gB", "<cmd>FzfLua git_branches<cr>", desc = "Branches" },
      { "<leader>gz", "<cmd>FzfLua git_stash<cr>", desc = "Stashes" },
    },
    opts = {
      { "default-title", "hide" },
      ui_select = {},
      winopts = {
        height = 0.85,
        width = 0.85,
        preview = {
          default = "builtin",
          vertical = "down:45%",
          horizontal = "right:50%",
          scrollbar = "float",
        },
      },
      keymap = {
        builtin = {
          ["<C-/>"] = "toggle-help",
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
        fzf = {
          ["ctrl-d"] = "preview-page-down",
          ["ctrl-u"] = "preview-page-up",
          ["ctrl-q"] = "select-all+accept",
        },
      },
      files = {
        formatter = "path.filename_first",
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
      },
      grep = {
        rg_opts = [[--column --line-number --no-heading --color=always --smart-case ]]
          .. [[--max-columns=4096 --hidden --glob=!.git/ -e]],
      },
      lsp = {
        code_actions = { previewer = "codeaction_native" },
        jump1 = true,
      },
      previewers = {
        builtin = { syntax_limit_b = 1024 * 100 },
      },
    },
    config = function(_, opts)
      require("fzf-lua").setup(opts)
    end,
  },

  {
    -- Persistent left project tree. Opens in its own window; files open in the
    -- previous editing window so the tree stays put.
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-mini/mini.icons",
    },
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Toggle file tree",
      },
      {
        "<leader>E",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = vim.fn.expand("%:p:h"),
            reveal = true,
          })
        end,
        desc = "Toggle file tree (buffer dir)",
      },
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({
            action = "focus",
            source = "filesystem",
            reveal = true,
          })
        end,
        desc = "Reveal current file in tree",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      -- Claim netrw early so `:edit directory` opens Neo-tree, not netrw.
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = true,
        content_layout = "center",
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          default = "",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
      window = {
        position = "left",
        width = 32,
        mapping_options = { noremap = true, nowait = true },
        mappings = {
          ["<space>"] = "none", -- leader lives here; don't steal it
          ["<cr>"] = "open",
          ["l"] = "open",
          ["h"] = "close_node",
          ["z"] = "close_all_nodes",
          ["Z"] = "expand_all_nodes",
          ["a"] = { "add", config = { show_path = "relative" } },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
          ["<C-t>"] = "open_tabnew",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          -- Do not steal Ctrl window navigation.
          ["<C-h>"] = "none",
          ["<C-j>"] = "none",
          ["<C-k>"] = "none",
          ["<C-l>"] = "none",
          ["<C-w>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path)
              vim.notify("Copied: " .. path)
            end,
            desc = "Copy path to clipboard",
          },
        },
      },
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true, leave_dirs_open = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".git", "node_modules", "target", "__pycache__", ".venv" },
        },
        window = {
          mappings = {
            ["<bs>"] = "navigate_up",
          },
        },
      },
    },
  },

  {
    -- Buffer-as-directory editor. Useful for batch rename/create; not the
    -- primary project tree (that's Neo-tree).
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" },
    },
    opts = {
      -- Neo-tree owns directory buffers / netrw. Oil is opt-in via `-`.
      default_file_explorer = false,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = { show_hidden = true },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["q"] = "actions.close",
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
      },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = false },
        char = { jump_labels = true },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
    },
  },
}
