-- Autocommands.

local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- Briefly highlight yanked text. (vim.highlight was renamed to vim.hl in 0.11.)
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Equalise splits when the terminal is resized, keeping the current tab.
autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Close throwaway windows with q, and keep them out of the buffer list.
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "man", "qf", "checkhealth", "lspinfo", "startuptime", "notify",
    "query", "fugitive", "git", "gitsigns-blame", "dap-float", "grug-far",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { buffer = ev.buf, silent = true, desc = "Close window" })
    end)
  end,
})

-- Restore the last cursor position, unless the mark is stale or this is a
-- commit message (where starting at the top is what you want).
autocmd("BufReadPost", {
  group = augroup("last_location"),
  callback = function(ev)
    local exclude = { "gitcommit", "gitrebase", "commit" }
    if vim.tbl_contains(exclude, vim.bo[ev.buf].filetype) or vim.b[ev.buf].last_location then
      return
    end
    vim.b[ev.buf].last_location = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd("normal! zvzz")
    end
  end,
})

-- Create missing parent directories when writing a new file.
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Trim trailing whitespace on save, except where it is significant.
autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  callback = function(ev)
    if vim.tbl_contains({ "markdown", "diff", "gitsendemail", "mail" }, vim.bo[ev.buf].filetype) then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Prose settings for text-like filetypes.
autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "tex", "plaintex", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.linebreak = true
    -- Move by visual line while wrapped, but only for bare j/k so that counts
    -- (5j) still operate on real lines and stay consistent with the gutter.
    vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, buffer = true })
    vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, buffer = true })
  end,
})

-- Assembly: you write NASM (x86-64). Forcing filetype `asm` used the generic
-- tree-sitter grammar, which mishighlights `section`/`global`/Intel mnemonics.
-- `.s`/`.S` stay GAS (`asm`); `.asm`/`.inc` are NASM.
vim.g.asmsyntax = "nasm"

vim.filetype.add({
  extension = {
    asm = "nasm",
    inc = "nasm",
    s = "asm",
    S = "asm",
    tpp = "cpp",
    ixx = "cpp",
    mdx = "markdown",
  },
  filename = {
    ["Rakefile"] = "ruby",
    ["Gemfile"] = "ruby",
    ["Vagrantfile"] = "ruby",
    ["Dockerfile"] = "dockerfile",
    ["compile_flags.txt"] = "conf",
    [".clang-format"] = "yaml",
  },
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github",
    ["Dockerfile%..*"] = "dockerfile",
  },
})

-- Disable expensive features in very large files so they stay editable.
autocmd("BufReadPre", {
  group = augroup("big_file"),
  callback = function(ev)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if not (ok and stats and stats.size > 1024 * 1024) then return end
    vim.b[ev.buf].big_file = true
    vim.bo[ev.buf].swapfile = false
    vim.bo[ev.buf].undofile = false
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = false
    vim.schedule(function()
      pcall(vim.treesitter.stop, ev.buf)
      vim.bo[ev.buf].syntax = "off"
    end)
    vim.notify("Large file: syntax and folds disabled", vim.log.levels.WARN)
  end,
})
