-- ruff: Python linting, import sorting and formatting, in one fast binary.
--
-- Hover is disabled so that basedpyright is the single source of type
-- information and you do not get two competing popups.

return {
  init_options = {
    settings = {
      lineLength = 88,
      showSyntaxErrors = true,
      organizeImports = true,
      fixAll = true,
    },
  },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
