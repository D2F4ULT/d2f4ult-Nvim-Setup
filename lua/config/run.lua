-- Compile / run the current file with the real toolchain, shown in a terminal.
-- Project-aware when a marker exists (CMakeLists.txt, Cargo.toml, …); otherwise
-- a single-file command so CS exercises still work.

local M = {}

local function term(cmd, cwd)
  local ok = pcall(function()
    Snacks.terminal(cmd, {
      cwd = cwd or vim.fn.expand("%:p:h"),
      win = { position = "bottom", height = 0.3 },
      auto_close = false,
    })
  end)
  if not ok then
    vim.cmd("split | resize 12 | terminal " .. cmd)
  end
end

local function root_has(name)
  return vim.fs.root(0, { name })
end

function M.compile_run()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local stem = vim.fn.expand("%:t:r")

  if ft == "c" then
    if root_has("CMakeLists.txt") then
      term("cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build && echo built", dir)
    elseif root_has("Makefile") then
      term("make", dir)
    else
      term(string.format("clang -g -Wall -Wextra '%s' -o '/tmp/%s' && /tmp/'%s'", file, stem, stem), dir)
    end
  elseif ft == "cpp" then
    if root_has("CMakeLists.txt") then
      term("cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build && echo built", dir)
    elseif root_has("Makefile") then
      term("make", dir)
    else
      term(string.format("clang++ -g -Wall -Wextra -std=c++23 '%s' -o '/tmp/%s' && /tmp/'%s'", file, stem, stem), dir)
    end
  elseif ft == "python" then
    local py = os.getenv("VIRTUAL_ENV") and (os.getenv("VIRTUAL_ENV") .. "/bin/python") or "python3"
    term(string.format("%s '%s'", py, file), dir)
  elseif ft == "rust" then
    if root_has("Cargo.toml") then
      term("cargo run", vim.fs.root(0, { "Cargo.toml" }))
    else
      term(string.format("rustc '%s' -o '/tmp/%s' && /tmp/'%s'", file, stem, stem), dir)
    end
  elseif ft == "ruby" then
    if root_has("Gemfile") and vim.fn.executable("bundle") == 1 then
      term("bundle exec ruby " .. vim.fn.shellescape(file), vim.fs.root(0, { "Gemfile" }))
    else
      term("ruby " .. vim.fn.shellescape(file), dir)
    end
  elseif ft == "java" then
    if root_has("pom.xml") then
      term("mvn -q compile exec:java", vim.fs.root(0, { "pom.xml" }))
    elseif root_has("build.gradle") or root_has("build.gradle.kts") then
      term("./gradlew run", vim.fs.root(0, { "build.gradle", "build.gradle.kts" }))
    else
      term(string.format("javac '%s' -d /tmp && java -cp /tmp '%s'", file, stem), dir)
    end
  elseif ft == "haskell" then
    if root_has("cabal.project") or vim.fn.glob("*.cabal") ~= "" then
      term("cabal run", dir)
    elseif root_has("stack.yaml") then
      term("stack run", dir)
    else
      term(string.format("runghc '%s'", file), dir)
    end
  elseif ft == "nasm" or (ft == "asm" and vim.fn.expand("%:e") ~= "s" and vim.fn.expand("%:e") ~= "S") then
    term(string.format("nasm -f elf64 -g -F dwarf '%s' -o '/tmp/%s.o' && ld '/tmp/%s.o' -o '/tmp/%s' && /tmp/'%s'", file, stem, stem, stem, stem), dir)
  elseif ft == "asm" then
    -- GAS (.s / .S)
    term(string.format("gcc -g '%s' -o '/tmp/%s' && /tmp/'%s'", file, stem, stem), dir)
  elseif ft == "lua" then
    term("lua " .. vim.fn.shellescape(file), dir)
  elseif ft == "javascript" then
    term("node " .. vim.fn.shellescape(file), dir)
  elseif ft == "typescript" then
    term("npx --yes tsx " .. vim.fn.shellescape(file), dir)
  elseif ft == "tex" or ft == "plaintex" then
    vim.cmd("VimtexCompile")
  else
    vim.notify("No run rule for filetype: " .. ft, vim.log.levels.WARN)
  end
end

return M
