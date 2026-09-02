-- jsonls, with SchemaStore catalogues for package.json, tsconfig, and friends.

return {
  settings = {
    json = {
      validate = { enable = true },
    },
  },
  before_init = function(_, config)
    local ok, schemastore = pcall(require, "schemastore")
    if ok then
      config.settings.json.schemas = schemastore.json.schemas()
    end
  end,
}
