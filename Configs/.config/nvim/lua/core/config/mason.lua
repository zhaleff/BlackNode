require("mason").setup({
  ui = {
    border = "single",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  },
  max_concurrent_installers = 4,
})

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { 
          globals = { "vim" },
          disable = { "missing-fields" }
        },
        workspace = { 
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
          maxPreload = 2000,
          preloadFileSize = 50000
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
        }
      }
    }
  },

  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          autoImportCompletions = true,
          -- Opciones para reducir consumo
          indexing = true,
          importFormat = "absolute",
        }
      }
    }
  },

  tailwindcss = {
    filetypes = {
      "html", "javascript", "typescript", "javascriptreact", 
      "typescriptreact", "vue", "svelte", "astro", "php",
      "blade", "twig", "erb", "heex", "elixir"
    },
    settings = {
      tailwindCSS = {
        experimental = {
          classRegex = {
            "class: \"([^\"]*)\"",
            "className: \"([^\"]*)\"",
            "classNames: \"([^\"]*)\"",
            "tw`([^`]*)`",
            "tw=\"([^\"]*)\"",
            "tw={\"([^\"}]*)\"}",
          }
        },
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
          recommendedVariantOrder = "warning"
        }
      }
    },
    init_options = {
      userLanguages = {
        elixir = "html-eex",
        erb = "html",
        heex = "html-eex",
      }
    },
    flags = {
      debounce_text_changes = 200,
    },
    setup = {
      cmd = { "tailwindcss-language-server", "--stdio" }
    }
  },

  html = {
    filetypes = { "html", "htmldjango", "blade", "php", "vue", "svelte" },
    settings = {
      html = {
        suggest = {},
        validate = { scripts = true, styles = true }
      }
    }
  },

  cssls = {
    filetypes = { "css", "scss", "less", "sass" },
    settings = {
      css = {
        validate = true,
        lint = {
          unknownAtRules = "ignore"
        }
      },
      scss = { validate = true },
      less = { validate = true },
      sass = { validate = true }
    }
  },


 
  emmet_language_server = {
    filetypes = {
      "html", "css", "scss", "less", "sass", "javascript", "typescript",
      "javascriptreact", "typescriptreact", "vue", "svelte", "php", "blade"
    },
    init_options = {
      html = {
        options = {
          ["bem.enabled"] = true,
        },
      },
    },
  },
}


require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "html",
    "cssls",
    "bashls",
    "jsonls",
    "tailwindcss",
    "emmet_language_server",
  },
  automatic_installation = true,
  
  handlers = {
    function(server_name)
      local opts = servers[server_name] or {}
      opts.capabilities = capabilities
      
      if server_name == "tailwindcss" then
        local util = require("lspconfig.util")
        local bin_path = util.path.join(
          vim.fn.stdpath("data"),
          "mason",
          "bin",
          "tailwindcss-language-server"
        )
        
        if vim.fn.executable(bin_path) == 1 then
          opts.cmd = { bin_path, "--stdio" }
        else
          opts.cmd = { "npx", "@tailwindcss/language-server", "--stdio" }
        end
      end
      
      require("lspconfig")[server_name].setup(opts)
    end,
    
    ["ltex"] = function()
      require("lspconfig").ltex.setup({
        capabilities = capabilities,
        settings = {
          ltex = {
            language = "es",
            dictionary = {},
            disabledRules = {},
            hiddenFalsePositives = {},
          }
        },
        on_attach = function(client, bufnr)
        end
      })
    end,
    
    -- Configuración especial para tsserver
    ["tsserver"] = function()
      require("lspconfig").tsserver.setup({
        capabilities = capabilities,
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
            disableSuggestions = true,
          },
        },
      })
    end,
  }
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    
    -- Diagnostic keymaps
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
    
local client = vim.lsp.get_client_by_id(ev.data.client_id)
if client and client.name == "tailwindcss" then
    client.config.cmd = {
        'systemd-run',
        '--user',
        '--scope',
        '-p', 'MemoryMax=420M',
        'tailwindcss-language-server',
        '--stdio'
    }
    vim.notify("TailwindCSS LSP - Programming Web :>")
end
  end,
})

