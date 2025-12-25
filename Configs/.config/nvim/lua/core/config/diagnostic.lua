-- Configuración de diagnósticos mejorada
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR }, -- Solo errores en línea
    prefix = "●",
    format = function(diagnostic)
      return string.format("%s", diagnostic.message:match("([^\n]+)"))
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  float = {
    border = "single",
    source = "if_many",
    format = function(diagnostic)
      return string.format("%s: %s", diagnostic.source, diagnostic.message)
    end,
  },
  update_in_insert = false, -- No actualizar mientras escribes
  severity_sort = true,
})

-- Comando para toggle de diagnósticos
local diagnostics_active = true
vim.api.nvim_create_user_command("ToggleDiagnostics", function()
  diagnostics_active = not diagnostics_active
  vim.diagnostic.config({
    virtual_text = diagnostics_active and { severity = { min = vim.diagnostic.severity.ERROR } } or false,
    underline = diagnostics_active and { severity = { min = vim.diagnostic.severity.WARN } } or false,
    signs = diagnostics_active,
  })
  vim.notify("Diagnósticos " .. (diagnostics_active and "activados" or "desactivados"))
end, {})

-- Atajo para el toggle
vim.keymap.set("n", "<leader>ud", "<cmd>ToggleDiagnostics<CR>", { desc = "Toggle diagnostics" })

