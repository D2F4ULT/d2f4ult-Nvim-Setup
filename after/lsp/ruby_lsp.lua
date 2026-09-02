-- ruby-lsp (Shopify): the actively maintained Ruby server, replacing solargraph.
--
-- Rails: ruby-lsp detects a Rails app and loads the `ruby-lsp-rails` addon,
-- which adds go-to-definition for models/controllers, route and migration
-- awareness, and schema information on hover. Add it to the project's Gemfile:
--
--     group :development do
--       gem "ruby-lsp", require: false
--       gem "ruby-lsp-rails", require: false
--     end
--
-- When a project has its own bundled ruby-lsp, prefer it over Mason's copy so
-- that the server matches the project's gems and Ruby version.

return {
  init_options = {
    formatter = "auto",
    linters = { "rubocop" },
    enabledFeatures = {
      codeActions = true,
      diagnostics = true,
      documentHighlights = true,
      documentSymbols = true,
      formatting = true,
      hover = true,
      inlayHint = true,
      completion = true,
      definition = true,
      references = true,
      signatureHelp = true,
    },
  },
  root_markers = { "Gemfile", ".ruby-lsp", ".git" },
}
