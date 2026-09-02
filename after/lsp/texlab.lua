-- texlab: LaTeX diagnostics, symbols, references and citation completion.
--
-- Compilation and PDF viewing are VimTeX's job (<localleader>ll and
-- <localleader>lv), so texlab's own build-on-save and forward search are off.
-- Running both would compile every document twice.

return {
  settings = {
    texlab = {
      build = { onSave = false },
      forwardSearch = { executable = "zathura", args = { "--synctex-forward", "%l:1:%f", "%p" } },
      chktex = { onOpenAndSave = true, onEdit = false },
      diagnosticsDelay = 300,
      formatterLineLength = 100,
      latexFormatter = "latexindent",
      latexindent = { modifyLineBreaks = false },
    },
  },
}
