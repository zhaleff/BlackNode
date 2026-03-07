-- core/lsp/capabilities.lua
local capabilities = vim.lsp.protocol.make_client_capabilities()

local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
end

-- Extras comunes que todo LSP moderno debería soportar
capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" }
}

return capabilities
