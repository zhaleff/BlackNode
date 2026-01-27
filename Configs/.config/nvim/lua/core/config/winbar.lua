local navic = require("nvim-navic")

local on_attach = function(client, bufnr)
  -- Conectar navic si el LSP lo soporta
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  -- tus keymaps LSP aquí
end

