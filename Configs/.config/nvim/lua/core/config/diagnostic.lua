-- ===== Tiny Inline Diagnostic Modernizado para Neovim 0.12+ =====
local diagnostics_active = true

-- Función para inicializar diagnósticos
local function update_diagnostics()
  local tiny_inline = require("tiny-inline-diagnostic")

  -- Configura tiny-inline
  tiny_inline.setup({
    preset = "minimal",
    transparent_bg = false,
    transparent_cursorline = true,
    hi = {
      error = "DiagnosticError",
      warn = "DiagnosticWarn",
      info = "DiagnosticInfo",
      hint = "DiagnosticHint",
      arrow = "NonText",
      background = "CursorLine",
      mixing_color = "Normal",
    },
    disabled_ft = {},
    options = {
      show_source = { enabled = false, if_many = false },
      use_icons_from_diagnostic = false,
      set_arrow_to_diag_color = false,
      throttle = 20,
      softwrap = 30,
      add_messages = {
        messages = true,
        display_count = false,
        use_max_severity = false,
        show_multiple_glyphs = true,
      },
      multilines = { enabled = false, always_show = false, trim_whitespaces = false, tabstop = 4 },
      show_all_diags_on_cursorline = false,
      show_diags_only_under_cursor = false,
      show_related = { enabled = true, max_count = 3 },
      enable_on_insert = false,
      enable_on_select = false,
      overflow = { mode = "wrap", padding = 0 },
      break_line = { enabled = false, after = 30 },
      format = nil,
      virt_texts = { priority = 2048 },
      severity = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
      },
      experimental = { use_window_local_extmarks = false },
    },
  })

  -- Configura vim.diagnostic nativo
  vim.diagnostic.config({
    virtual_text = false, -- tiny-inline ya muestra texto virtual
    signs = diagnostics_active,
    underline = diagnostics_active and { severity = { min = vim.diagnostic.severity.WARN } } or false,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "single",
      source = "if_many",
      format = function(d)
        return string.format("%s [%s]: %s", d.source, d.code or "", d.message)
      end,
    },
  })
end

-- Inicializa diagnósticos
update_diagnostics()

-- Comando para alternar
vim.api.nvim_create_user_command("ToggleDiagnostics", function()
  diagnostics_active = not diagnostics_active
  update_diagnostics()
  vim.notify("Diagnósticos " .. (diagnostics_active and "activados" or "desactivados"))
end, {})

-- Keymaps
vim.keymap.set("n", "<leader>ud", "<cmd>ToggleDiagnostics<CR>", { desc = "Toggle diagnostics" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Mostrar diagnostic float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Anterior diagnóstico" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Siguiente diagnóstico" })

