-- core/lsp/registry.lua
-- Configuración detallada de cada servidor (sin capabilities)
return {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each" },
          disable = { "missing-fields" },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = { enable = false },
        hint = {
          enable = true,
          arrayIndex = "Disable",
          await = true,
          paramName = "All",
          paramType = true,
          semicolon = "SameLine",
          setType = true,
        },
      },
    },
  },
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "standard",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          inlayHints = {
            callArgumentNames = true,
            functionReturnTypes = true,
            variableTypes = true,
          },
        },
      },
    },
  },
  vtsls = {
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "svelte", "astro" },
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = { enabled = "all" },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
      },
    },
  },
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--pch-storage=memory",
      "--offset-encoding=utf-16",
      "--j=4",
    },
    root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true, loadOutDirsFromCheck = true },
        checkOnSave = { command = "clippy" },
        procMacro = { enable = true },
        inlayHints = {
          bindingModeHints = { enable = true },
          chainingHints = { enable = true },
          closureReturnTypeHints = { enable = "always" },
          lifetimeElisionHints = { enable = "always" },
          parameterHints = { enable = true },
          typeHints = { enable = true },
        },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        staticcheck = true,
        usePlaceholders = true,
        completeUnimported = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          constantValues = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },
  jdtls = {
    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        references = { includeDecompiledSources = true },
        inlayHints = { parameterNames = { enabled = "all" } },
        format = { enabled = false },
      },
    },
  },
  html = {
    filetypes = { "html", "htmldjango", "blade", "php", "vue", "svelte", "astro" },
  },
  cssls = {
    filetypes = { "css", "scss", "less", "sass" },
    settings = { css = { validate = true, lint = { unknownAtRules = "ignore" } } },
  },
  tailwindcss = {
    filetypes = {
      "html", "javascript", "typescript", "javascriptreact", "typescriptreact",
      "vue", "svelte", "astro", "php", "blade",
    },
  },
  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        validate = true,
        format = { enable = true },
        keyOrdering = false,
      },
    },
  },
  marksman = {},
  bashls = { filetypes = { "sh", "bash", "zsh" } },
  dockerls = {},
  cmake = {},
  intelephense = {},
}
