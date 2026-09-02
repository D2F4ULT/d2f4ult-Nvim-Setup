-- Global keymaps.
--
-- Design rules, so this file stays small and predictable:
--
--  1. A <leader> key is either a standalone action or a group prefix, never
--     both. Mixing the two is what makes <leader>w hang waiting for a timeout.
--  2. Nothing here re-implements a motion Vim already has. Window management is
--     <C-w>, jumps are <C-o>/<C-i>, marks are m/', search is /. Learn those.
--  3. LSP mappings live in lua/plugins/lsp.lua (LspAttach), plugin mappings in
--     each plugin's `keys` table, so they are lazy-loaded with their plugin.
--
-- Groups: b buffer  c code  d debug  f find  g git  n notes  q session
--         r run     s search  t terminal  u toggle  x diagnostics

local map = vim.keymap.set

-- Write. Deliberately has no <leader>w* children so it fires immediately.
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })

-- Clear search highlight. Also stops an in-progress :substitute preview.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Bracket pairs. This is the vim-unimpaired convention and matches Neovim's own
-- built-in ]d/[d (diagnostics) and ]q/[q, so the whole family stays consistent.
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
map("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix item" })
map("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix item" })

-- Quickfix and location list are the native way to work through a set of
-- results (grep, diagnostics, compiler errors). Worth building the habit.
map("n", "<leader>xq", function()
  local open = false
  for _, w in ipairs(vim.fn.getwininfo()) do
    if w.quickfix == 1 and w.loclist == 0 then open = true end
  end
  vim.cmd(open and "cclose" or "copen")
end, { desc = "Toggle quickfix list" })

map("n", "<leader>xl", function()
  local ok = pcall(vim.cmd.lopen)
  if not ok then vim.notify("No location list", vim.log.levels.INFO) end
end, { desc = "Toggle location list" })

map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xQ", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
map("n", "<leader>xL", vim.diagnostic.setloclist, { desc = "Buffer diagnostics to loclist" })

-- Keep the selection after shifting, so > > > works from visual mode.
map("v", "<", "<gv", { desc = "Shift left and keep selection" })
map("v", ">", ">gv", { desc = "Shift right and keep selection" })

-- Terminal mode. <Esc><Esc> rather than a bare <Esc> so that <Esc> still
-- reaches full-screen terminal programs (lazygit, htop, an inner nvim).
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

-- Window navigation — explicit maps so which-key / buffer plugins cannot
-- swallow the follow-up key after <C-w>. Same directions as native Vim:
--   h left · j below · k above · l right
local win_dirs = {
  h = "left",
  j = "below",
  k = "above",
  l = "right",
}
for dir, label in pairs(win_dirs) do
  local go = function()
    vim.cmd.wincmd(dir)
  end
  map("n", "<C-w>" .. dir, go, { desc = "Window " .. label })
  -- Holding Ctrl through the second key (<C-w><C-h>) is also native Vim.
  map("n", "<C-w><C-" .. dir .. ">", go, { desc = "Window " .. label })
  -- One-keystroke form: works from Neo-tree / any buffer without a prefix.
  map("n", "<C-" .. dir .. ">", go, { desc = "Window " .. label })
  -- Leave a terminal split with the same keys.
  map("t", "<C-" .. dir .. ">", [[<C-\><C-n><C-w>]] .. dir, { desc = "Window " .. label })
end

-- Window splits. Close with <C-w>c. Create with these:
map("n", "<leader>|", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>_", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>=", "<C-w>=", { desc = "Equalise splits" })

-- Toggles.
map("n", "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, { desc = "Toggle wrap" })
map("n", "<leader>us", function() vim.wo.spell = not vim.wo.spell end, { desc = "Toggle spell check" })
map("n", "<leader>ul", function()
  vim.wo.number = not vim.wo.number
  vim.wo.relativenumber = vim.wo.number
end, { desc = "Toggle line numbers" })

map("n", "<leader>ud", function()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled)
  vim.notify("Diagnostics " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle diagnostics" })

map("n", "<leader>uh", function()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  vim.notify("Inlay hints " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle inlay hints" })

map("n", "<leader>uc", function()
  vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
end, { desc = "Toggle conceal" })
