-- Language-specific plugins that need more than after/lsp/*.lua.

return {
  {
    -- rust-analyzer + cargo commands + DAP wiring.
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { features = "all" },
              check = { command = "clippy" },
            },
          },
        },
      }
    end,
  },

  {
    -- Java LSP + debug/test adapters. Do not also enable jdtls via mason-lspconfig.
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local function start()
        local jdtls = require("jdtls")
        local home = vim.fn.stdpath("data")
        local workspace = home .. "/jdtls-workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local mason = home .. "/mason/packages"
        local jdtls_path = mason .. "/jdtls"
        local lombok = jdtls_path .. "/lombok.jar"
        local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        if launcher == "" then
          vim.notify("jdtls is not installed. Open :Mason and install jdtls.", vim.log.levels.WARN)
          return
        end

        local cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        }
        if vim.uv.fs_stat(lombok) then
          table.insert(cmd, "-javaagent:" .. lombok)
        end
        vim.list_extend(cmd, {
          "-jar", launcher,
          "-configuration", jdtls_path .. "/config_linux",
          "-data", workspace,
        })

        local bundles = {}
        local dbg = vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
        if dbg ~= "" then
          vim.list_extend(bundles, vim.split(dbg, "\n"))
        end
        local tests = vim.fn.glob(mason .. "/java-test/extension/server/*.jar", true)
        local skip = {
          ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
          ["jacocoagent.jar"] = true,
        }
        if tests ~= "" then
          for _, jar in ipairs(vim.split(tests, "\n")) do
            if jar ~= "" and not skip[vim.fn.fnamemodify(jar, ":t")] then
              table.insert(bundles, jar)
            end
          end
        end

        jdtls.start_or_attach({
          cmd = cmd,
          root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }) or vim.fn.getcwd(),
          settings = {
            java = {
              configuration = {
                runtimes = {
                  { name = "JavaSE-26", path = vim.env.JAVA_HOME or "/usr/lib/jvm/default", default = true },
                },
              },
              format = { enabled = false },
            },
          },
          init_options = { bundles = bundles },
          on_attach = function(_, bufnr)
            local map = function(lhs, rhs, desc)
              vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
            end
            map("<leader>co", jdtls.organize_imports, "Organize imports")
            map("<leader>dv", jdtls.test_class, "Debug test class")
            map("<leader>dn", jdtls.test_nearest_method, "Debug nearest test")
            jdtls.setup_dap({ hotcodereplace = "auto" })
            pcall(jdtls.setup_dap_main_class_configs)
          end,
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        group = vim.api.nvim_create_augroup("user_jdtls", { clear = true }),
        callback = start,
      })
      if vim.bo.filetype == "java" then
        start()
      end
    end,
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },
}
