# Neovim configuration

Keyboard-first setup for CS / systems work. Neovim 0.12+. Plugin manager: lazy.nvim.

## Backup / restore

A full snapshot of the previous config lives at:

```
~/nvim-backup-20260818-121853
```

Restore:

```bash
~/nvim-backup-20260818-121853/RESTORE.sh         # config only
~/nvim-backup-20260818-121853/RESTORE.sh --full  # config + plugins + Mason + state
```

## Layout

```
init.lua                 bootstrap
lua/config/              options, keymaps, autocmds, lazy, compile/run
lua/plugins/             one file per concern
after/lsp/               per-server LSP overrides (Neovim 0.12 native API)
ftplugin/                indent / comments per language
asm-lsp.toml             already installed to ~/.config/asm-lsp/.asm-lsp.toml (NASM + x86-64)
```

## Keymaps (leader = Space)

Pause after `<leader>` to see groups.

| Key | Action |
|---|---|
| `<leader><space>` | Find files |
| `<leader>/` | Grep project |
| `<leader>,` | Buffers |
| `<leader>e` | Toggle **left** project tree (Neo-tree) |
| `<leader>E` | Tree at buffer directory |
| `<leader>fe` | Reveal current file in tree |
| `-` | Oil: edit parent directory as a buffer |
| `<leader>w` | Write |
| `<leader>\|` / `<leader>_` | Vertical / horizontal split |
| `<leader>=` | Equalise splits |
| `<C-w>h/j/k/l` | Move between windows (native Vim) |
| `<leader>rr` | Compile / run current file |
| `<leader>tt` | Floating terminal |
| `s` / `S` | Flash jump / treesitter select |
| `K` | Hover (built-in) |
| `gd` | Definition |
| `grn` / `gra` / `grr` | Rename / code action / references (built-in) |
| `gcc` | Toggle comment (built-in) |
| `]d` `[d` | Diagnostics |
| `]h` `[h` | Git hunks |
| `F5` `F9` `F10` `F11` `F12` | Debug continue / breakpoint / over / into / out |

### Completion

`<C-n>` / `<C-p>` select · `<C-y>` accept · `<C-e>` dismiss · `<CR>` always newline

### Explorer

Neo-tree is the persistent left sidebar. Oil is only for `-`. Use `<C-w>h` / `<C-w>l` between tree and code.

Notes: `<leader>n*` · Git hunks: `<leader>h*` · Debug: `<leader>d*`

## Languages

LSP via Mason + `vim.lsp.enable()`. Java is `nvim-jdtls` (not enabled twice). Rust is `rustaceanvim`.

Format-on-save: conform.nvim. Disable: `:FormatDisable` / `:FormatDisable!` (buffer).

Debug: CodeLLDB for C/C++/Rust, debugpy for Python, jdtls bundles for Java, GDB DAP for assembly.

## Markdown

Vault is still `~/Desktop/DevLabProgig`. Notes are not moved.

## Missing system tools (optional)

Already present: gcc, clang, gdb, nasm, cmake, python3, ruby, cargo, ghc, java, latexmk, zathura, rg, fd, fzf, tree-sitter-cli.

Useful extras:

- `cabal` / `stack` — full Haskell project LSP
- `bundle` — Rails
- `mvn` / `gradle` — Java projects (single-file `javac` still works)
- `lazygit` — Git TUI in a terminal
- `asm-lsp.toml` is installed at `~/.config/asm-lsp/.asm-lsp.toml` (section must be `[default_config]`)

## Health

```
:checkhealth
:Lazy
:Mason
```
