return {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = { enable = false },
        hint = { enable = true },
      },
    },
  },

  vtsls = {
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = { enabled = "all" },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
        },
      },
    },
  },

  html = {
    filetypes = { "html", "javascriptreact", "typescriptreact" },
    settings = {
      html = {
        completion = { attributeDefaultValue = "doublequotes" },
      },
    },
  },

  cssls = {
    filetypes = { "css", "scss", "less" },
  },

  tailwindcss = {
    filetypes = {
      "html", "javascript", "javascriptreact",
      "typescript", "typescriptreact",
    },
  },

  rust_analyzer = {},

  kotlin_language_server = {
    init_options = {
      storagePath = vim.fn.stdpath("cache") .. "/kotlin-lsp",
    },
  },
}
