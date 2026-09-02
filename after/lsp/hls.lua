-- haskell-language-server.
--
-- HLS needs a project description to do much: a .cabal file, package.yaml or
-- stack.yaml. On a loose .hs file it falls back to a single-file session with
-- reduced features. `cabal` or `stack` must be installed for full project
-- support -- with only ghc present, expect diagnostics but limited navigation.

return {
  settings = {
    haskell = {
      formattingProvider = "fourmolu",
      cabalFormattingProvider = "cabalfmt",
      plugin = {
        stan = { globalOn = false }, -- noisy, and slow on large projects
      },
    },
  },
  root_markers = { "hie.yaml", "stack.yaml", "cabal.project", "package.yaml", "*.cabal", ".git" },
}
