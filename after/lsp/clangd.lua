-- clangd: C and C++.
--
-- clangd needs to know your compile flags. In order of preference:
--   1. CMake: `cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`, which writes
--      build/compile_commands.json (`:CMakeGenerate` does this for you).
--   2. Make: `bear -- make` records the commands into compile_commands.json.
--   3. Single files or small exercises: a `compile_flags.txt` in the project
--      root, one flag per line, e.g.
--          -std=c++23
--          -Wall
--          -Iinclude
-- Without one of these, clangd guesses and header includes will look broken.

return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--all-scopes-completion",
    "--pch-storage=memory",
    "-j=4",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "CMakeLists.txt",
    "Makefile",
    "configure.ac",
    ".git",
  },
  on_attach = function(_, buf)
    -- Jump between a .c/.cpp and its header. This is a clangd extension, not
    -- part of the LSP spec, which is why it needs its own mapping.
    vim.keymap.set("n", "<leader>co", function()
      local params = { uri = vim.uri_from_bufnr(0) }
      vim.lsp.buf_request(0, "textDocument/switchSourceHeader", params, function(err, result)
        if err then
          vim.notify(tostring(err.message or err), vim.log.levels.ERROR)
          return
        end
        if not result or result == "" then
          vim.notify("No matching source/header", vim.log.levels.WARN)
          return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
      end)
    end, { buffer = buf, desc = "LSP: Switch source/header" })
  end,
}
