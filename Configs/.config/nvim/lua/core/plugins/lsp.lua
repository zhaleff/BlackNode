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
      local capabilities = require("core.lsp.capabilities")
      local registry     = require("core.lsp.registry")

      local function on_attach(client, bufnr)
        -- Deja el formateo 100% en manos de conform.nvim, evita doble
        -- formateo o estilos peleando entre LSP y formatter externo.
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        -- Activa inlay hints automáticamente si el servidor los soporta.
        if client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end

      for name, config in pairs(registry) do
        vim.lsp.config[name] = vim.tbl_deep_extend("force", config, {
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end
      vim.lsp.enable(vim.tbl_keys(registry))

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
        callback = function(ev)
          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          map("n", "gd",         vim.lsp.buf.definition,      "Ir a definición")
          map("n", "gD",         vim.lsp.buf.declaration,     "Ir a declaración")
          map("n", "gi",         vim.lsp.buf.implementation,  "Ir a implementación")
          map("n", "gt",         vim.lsp.buf.type_definition, "Ir a tipo")
          map("n", "gr",         vim.lsp.buf.references,      "Referencias")

          map("n", "K", function()
            local ok, ufo = pcall(require, "ufo")
            local winid = ok and ufo.peekFoldedLinesUnderCursor()
            if not winid then vim.lsp.buf.hover() end
          end, "Hover / Peek fold")

          map("n", "<C-k>",      vim.lsp.buf.signature_help,  "Signature help")
          map("n", "<leader>ca", vim.lsp.buf.code_action,     "Code action")
          map("v", "<leader>ca", vim.lsp.buf.code_action,     "Code action (visual)")
          map("n", "<leader>rn", vim.lsp.buf.rename,          "Rename")
          map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Formatear")
          map("n", "<leader>e",  vim.diagnostic.open_float,   "Ver diagnóstico")
          map("n", "[d",         vim.diagnostic.goto_prev,    "Diagnóstico anterior")
          map("n", "]d",         vim.diagnostic.goto_next,    "Diagnóstico siguiente")
          map("n", "<leader>q",  vim.diagnostic.setloclist,   "Lista de diagnósticos")

          map("n", "<leader>ih", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
          end, "Toggle inlay hints")

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight") then
            local group = vim.api.nvim_create_augroup("UserLspHighlight_" .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = ev.buf, group = group, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
              buffer = ev.buf, group = group, callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      vim.diagnostic.config({
        virtual_text = {
          severity = { min = vim.diagnostic.severity.WARN },
          source   = "if_many",
          spacing  = 2,
          prefix   = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
        underline        = true,
        severity_sort    = true,
        update_in_insert = false,
        float = {
          border     = "single",
          source     = "if_many",
          header     = "",
          prefix     = "",
          focusable  = false,
        },
      })
    end,
  },
}
