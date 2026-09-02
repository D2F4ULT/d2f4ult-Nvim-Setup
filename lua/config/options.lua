-- Editor settings. Nothing here depends on a plugin being installed.

local o = vim.opt

-- Line numbers: absolute on the cursor line, relative elsewhere, so that
-- counts for motions (5j, d3k, :12) can be read straight off the gutter.
o.number = true
o.relativenumber = true

o.mouse = "a"
o.clipboard = "unnamedplus"
o.termguicolors = true
o.cursorline = true
o.signcolumn = "yes"
o.laststatus = 3
o.showmode = false -- the statusline already shows it
o.cmdheight = 1
o.pumheight = 12
o.winborder = "rounded"

-- Indentation. Two spaces suits Lua/Ruby/JS/YAML; ftplugin/ overrides the
-- languages that conventionally use something else (C, C++, Java, Python).
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.shiftround = true
o.smartindent = true
o.breakindent = true

-- Wrapping is off for code and turned back on per-filetype for prose.
o.wrap = false
o.linebreak = true

o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.inccommand = "split" -- live preview of :substitute

o.splitright = true
o.splitbelow = true
o.splitkeep = "screen" -- don't scroll the current window when opening a split

o.scrolloff = 8
o.sidescrolloff = 8

o.undofile = true
o.undolevels = 10000
o.swapfile = false
o.backup = false
o.writebackup = false
o.updatetime = 200
o.timeoutlen = 400 -- how long which-key waits before showing
o.confirm = true -- prompt instead of failing on :q with unsaved changes

o.completeopt = "menu,menuone,noselect"
o.wildmode = "longest:full,full"
o.virtualedit = "block"
o.jumpoptions = "stack,view"

-- Folds: treesitter-driven, but everything starts open. `zc`/`zo`/`za` close,
-- open and toggle; `zR` opens all.
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
o.foldcolumn = "0"

o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
o.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸", foldsep = " ", diff = "╱" }

o.spelllang = { "en_us" }
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Providers we don't use. Skipping them removes work at startup and silences
-- the corresponding :checkhealth warnings.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- Disable unused built-in plugins.
for _, p in ipairs({ "gzip", "tarPlugin", "zipPlugin", "tutor", "rplugin" }) do
  vim.g["loaded_" .. p] = 1
end
