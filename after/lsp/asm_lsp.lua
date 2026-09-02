-- asm-lsp: hover documentation, completion, signature help and go-to-definition
-- for x86-64 assembly, in both GAS and NASM flavours.
--
-- Hovering an instruction gives you the reference manual entry, which is the
-- main reason to run this while learning the instruction set and the System V
-- AMD64 calling convention.
--
-- Diagnostics need a correctly shaped `.asm-lsp.toml`. The server reads one from
-- the project root (next to `.git`), then falls back to
-- ~/.config/asm-lsp/.asm-lsp.toml. The section MUST be `[default_config]` with
-- `compiler = "nasm"` under `[default_config.opts]` — a typo like `[default]`
-- is ignored and diagnostics fall back to bare `gcc`, which marks every NASM
-- line as "syntax error". See `asm-lsp.toml` in this config repo.
--
-- Generate interactively with: `asm-lsp gen-config`

return {
  filetypes = { "asm", "s", "S", "nasm", "vmasm" },
  root_markers = { ".asm-lsp.toml", "compile_commands.json", "compile_flags.txt", "Makefile", ".git" },
}
