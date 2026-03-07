-- core/mason/init.lua
local M = {}

function M.setup(profile_name)
  -- 1. Cargar perfil (lista de servidores)
  local profile_ok, profile_servers = pcall(require, "profiles." .. profile_name)
  if not profile_ok then
    vim.notify("Perfil LSP '" .. profile_name .. "' no encontrado. Usando 'minimal'.", vim.log.levels.WARN)
    local profile_ok, profile_servers = pcall(require, "core.mason.profiles." .. profile_name)
  end

  if type(profile_servers) ~= "table" then
    vim.notify("El perfil debe retornar una tabla de nombres de servidores.", vim.log.levels.ERROR)
    return
  end

  -- 2. Obtener capacidades y registro
  local capabilities = require("core.lsp.capabilities")
  local registry = require("core.lsp.registry")

  -- 3. Configurar Mason
  require("mason").setup({
    ui = {
      border = "rounded",
      icons = {
        package_installed = "✓",
        package_pending = "⟳",
        package_uninstalled = "✗",
      },
      height = 0.85,
      width = 0.85,
    },
    max_concurrent_installers = 4,
    log_level = vim.log.levels.INFO,
  })

  -- 4. Asegurar instalación de los servidores del perfil
  require("mason-lspconfig").setup({
    ensure_installed = profile_servers,
    automatic_installation = true,
  })

  -- 5. Registrar cada servidor con su configuración + capacidades
  for _, server_name in ipairs(profile_servers) do
    local server_config = registry[server_name]
    if server_config then
      local config = vim.tbl_deep_extend("force", server_config, { capabilities = capabilities })
      vim.lsp.config[server_name] = config
    else
      vim.notify("No hay configuración en registry para: " .. server_name, vim.log.levels.WARN)
    end
  end

  -- 6. Habilitar los servidores
  vim.lsp.enable(profile_servers)
end

return M
