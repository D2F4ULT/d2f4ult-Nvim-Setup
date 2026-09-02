-- yamlls. Schemas come from SchemaStore, so CI configs, Docker Compose files
-- and Kubernetes manifests get completion and validation without extra setup.

return {
  settings = {
    yaml = {
      keyOrdering = false, -- do not complain about key order
      validate = true,
      format = { enable = true },
      schemaStore = { enable = false, url = "" }, -- SchemaStore.nvim supplies these
    },
    redhat = { telemetry = { enabled = false } },
  },
  before_init = function(_, config)
    local ok, schemastore = pcall(require, "schemastore")
    if ok then
      config.settings.yaml.schemas = schemastore.yaml.schemas()
    end
  end,
}
