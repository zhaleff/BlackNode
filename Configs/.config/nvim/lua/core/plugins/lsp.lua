return {
  "neovim/nvim-lspconfig",
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local capabilities = require("core.lsp.capabilities")
    local registry = require("core.lsp.registry")

    for name, config in pairs(registry) do
      vim.lsp.config[name] = vim.tbl_deep_extend("force", config, {
        capabilities = capabilities,
      })
    end
    vim.lsp.enable(vim.tbl_keys(registry))

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client then
          -- Deja el formateo 100% en manos de conform.nvim.
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end

        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Ir a definición")
        map("n", "gD", vim.lsp.buf.declaration, "Ir a declaración")
        map("n", "gi", vim.lsp.buf.implementation, "Ir a implementación")
        map("n", "gr", vim.lsp.buf.references, "Referencias")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>e", vim.diagnostic.open_float, "Ver diagnóstico")
        map("n", "[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
        map("n", "]d", vim.diagnostic.goto_next, "Diagnóstico siguiente")

        if client and client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end
      end,
    })

    vim.diagnostic.config({
      virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        spacing = 2,
        prefix = "●",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.HINT] = "",
          [vim.diagnostic.severity.INFO] = "",
        },
      },
      underline = true,
      severity_sort = true,
      update_in_insert = false,
      float = { border = "single", focusable = false },
    })
  end,
}
