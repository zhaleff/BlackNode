return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- ── Capabilities ────────────────────────────────────────────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
      end

      -- Folding (para plugins como nvim-ufo si los usas después)
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- ── Registrar servidores ─────────────────────────────────────────────
      local registry = require("core.lsp.registry")

      for name, config in pairs(registry) do
        vim.lsp.config[name] = vim.tbl_deep_extend("force", config, {
          capabilities = capabilities,
        })
      end

      vim.lsp.enable(vim.tbl_keys(registry))

      -- ── Keymaps (solo cuando hay LSP activo en el buffer) ────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
        callback = function(ev)
          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end

          -- Navegación
          map("n", "gd", vim.lsp.buf.definition, "Ir a definición")
          map("n", "gD", vim.lsp.buf.declaration, "Ir a declaración")
          map("n", "gi", vim.lsp.buf.implementation, "Ir a implementación")
          map("n", "gt", vim.lsp.buf.type_definition, "Ir a tipo")
          map("n", "gr", vim.lsp.buf.references, "Referencias")
          map("n", "K", vim.lsp.buf.hover, "Hover docs")
          map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

          -- Acciones
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("v", "<leader>ca", vim.lsp.buf.code_action, "Code action (visual)")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, "Formatear")

          -- Diagnósticos
          map("n", "<leader>e", vim.diagnostic.open_float, "Ver diagnóstico")
          map("n", "[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
          map("n", "]d", vim.diagnostic.goto_next, "Diagnóstico siguiente")
          map("n", "<leader>q", vim.diagnostic.setloclist, "Lista de diagnósticos")

          -- Inlay hints (toggle)
          map("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, "Toggle inlay hints")
        end,
      })

      vim.diagnostic.config({
        virtual_text     = false, -- tiny-inline-diagnostic lo maneja mejor
        signs            = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
        underline        = true,
        severity_sort    = true,
        update_in_insert = false, -- no molesta mientras escribes
        float            = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
      })
    end,
  },
}
