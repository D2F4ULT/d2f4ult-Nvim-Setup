-- basedpyright: Python type checking and navigation.
--
-- Formatting and linting are ruff's job (see after/lsp/ruff.lua), so the
-- overlapping analysis here is turned down rather than duplicated.
--
-- Virtualenvs: basedpyright picks up an activated venv from $VIRTUAL_ENV, and
-- otherwise looks for ./.venv or ./venv next to the project root. Activate the
-- venv before launching Neovim, or use <leader>cv to select one at runtime.

return {
  settings = {
    basedpyright = {
      disableOrganizeImports = true, -- ruff does this
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "standard",
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
        },
      },
    },
  },
}
