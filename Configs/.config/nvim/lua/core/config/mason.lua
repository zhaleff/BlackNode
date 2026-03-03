local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = cmp_lsp.default_capabilities()
end

require("mason").setup({
  ui = {
    border = "single",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
  max_concurrent_installers = 4,
})


local servers = {
  -- Lua
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
          globals = { "vim" },
          disable = { "missing-fields" },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
          maxPreload = 2000,
          preloadFileSize = 50000,
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

  -- Python
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          autoImportCompletions = true,
          indexing = true,
          importFormat = "absolute",
        },
      },
    },
  },

  ts_ls = {
    settings = {
      typescript = {
        format = { enable = false },
        inlayHints = {
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },
        suggest = {
          completeFunctionCalls = true,
        },
      },
      javascript = {
        format = { enable = false },
        inlayHints = {
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },
        suggest = {
          completeFunctionCalls = true,
        },
      },
    },
    init_options = {
      preferences = {
        disableSuggestions = true, },


    },
  },

  -- JSON
  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(), -- Si usas nvim-schemastore
        validate = { enable = true },
      },
    },
  },

  -- HTML
  html = {
    filetypes = { "html", "htmldjango", "blade", "php", "vue", "svelte" },
    settings = {
      html = {
        suggest = {},
        validate = { scripts = true, styles = true },
      },
    },
  },

  -- CSS / SCSS / Less
  cssls = {
    filetypes = { "css", "scss", "less", "sass" },
    settings = {
      css = {
        validate = true,
        lint = {
          unknownAtRules = "ignore",
        },
      },
      scss = { validate = true },
      less = { validate = true },
      sass = { validate = true },
    },
  },

  -- Tailwind CSS
  tailwindcss = {
    filetypes = {
      "html", "javascript", "typescript", "javascriptreact",
      "typescriptreact", "vue", "svelte", "astro", "php",
      "blade", "twig", "erb", "heex", "elixir",
    },
    settings = {
      tailwindCSS = {
        includeLanguages = {
          html = "html",
          javascript = "javascript",
          typescript = "typescript",
          javascriptreact = "javascriptreact",
          typescriptreact = "typescriptreact",
          vue = "vue",
          svelte = "svelte",
        },
        validate = true,
        lint = {
          cssConflict = "warning",
          invalidScreen = "error",
          invalidVariant = "error",
          invalidConfigPath = "error",
          invalidTailwindDirective = "error",
          recommendedVariantOrder = "warning",
        },
      },
    },
    init_options = {
      userLanguages = {
        elixir = "html-eex",
        erb = "html",
        heex = "html-eex",
      },
    },
  },

  -- Emmet
  emmet_language_server = {
    filetypes = {
      "html", "css", "scss", "less", "sass", "javascript", "typescript",
      "javascriptreact", "typescriptreact", "vue", "svelte", "php", "blade",
    },
    init_options = {
      html = {
        options = {
          ["bem.enabled"] = true,
        },
      },
    },
  },

  -- Bash
  bashls = {
    filetypes = { "sh", "bash", "zsh" },
  },

  -- YAML
  yamlls = {
    settings = {
      yaml = {
        keyOrdering = false,
        validate = true,
        format = { enable = true },
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*",
          ["https://json.schemastore.org/pre-ttierrc.json"] = ".prettierrc",
        },
      },
    },
  },

  -- Markdown
  marksman = {},
}
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = true,
})


for server_name, server_config in pairs(servers) do
  local config = vim.tbl_deep_extend("force", server_config, {
    capabilities = capabilities,
  })
  vim.lsp.config[server_name] = config
end

-- Habilitar todos los servidores definidos
vim.lsp.enable(vim.tbl_keys(servers))

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "vim", "vimdoc", "python", "javascript", "typescript",
    "html", "css", "scss", "json", "yaml", "bash", "markdown",
    "markdown_inline", "regex", "tsx", "svelte", "vue", "php",
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)

    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  end,
})
