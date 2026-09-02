-- LaTeX: VimTeX for compile / view / inverse search. texlab (after/lsp) handles LSP.

return {
  "lervag/vimtex",
  ft = { "tex", "plaintex", "bib" },
  init = function()
    vim.g.tex_flavor = "latex"
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_syntax_enabled = 0 -- treesitter highlights instead
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = "build",
      out_dir = "build",
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-shell-escape",
      },
    }
  end,
}
