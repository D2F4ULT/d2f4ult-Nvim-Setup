-- lua_ls. lazydev.nvim supplies the Neovim runtime library paths on demand, so
-- there is no need to stuff the whole runtime into `workspace.library` here.

return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = true, arrayIndex = "Disable" },
      format = { enable = false }, -- stylua handles formatting
      diagnostics = { unusedLocalExclude = { "_*" } },
      codeLens = { enable = true },
    },
  },
}
