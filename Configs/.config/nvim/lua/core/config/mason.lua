local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
end
capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } }

require("mason").setup({
  ui = { border = "rounded", height = 0.8, width = 0.8 },
  max_concurrent_installers = 3,
})

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
        hint = { enable = true },
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
        },
      },
    },
  },
  html = { filetypes = { "html", "blade", "php", "vue", "svelte", "astro" } },
  cssls = { filetypes = { "css", "scss", "less", "sass" } },
  tailwindcss = {
    filetypes = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte", "astro", "php", "blade" },
  },
  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },

  marksman = {},
  bashls = { filetypes = { "sh", "bash", "zsh" } },

}

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = false,
})

for name, config in pairs(servers) do
  vim.lsp.config[name] = vim.tbl_deep_extend("force", config, { capabilities = capabilities })
end

vim.lsp.enable(vim.tbl_keys(servers))

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  underline = true,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
    end
    map("gd", vim.lsp.buf.definition, "Definición")
    map("K", vim.lsp.buf.hover, "Hover")
    map("gr", vim.lsp.buf.references, "Referencias")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Formatear")
    -- map("[d", vim.diagnostic.goto_prev, "Anterior")
    -- map("]d", vim.diagnostic.goto_next, "Siguiente")
    map("<leader>e", vim.diagnostic.open_float, "Ver diagnostic")
  end,
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
    "html", "css", "scss", "json", "yaml", "markdown", "bash", "php",
    "vue", "svelte", "astro",
  },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = { enable = true },
})
