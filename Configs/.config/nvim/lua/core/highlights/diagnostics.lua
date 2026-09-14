local colors = require("core.highlights.colors")

local hl = vim.api.nvim_set_hl

hl(0, "DiagnosticError", { fg = colors.error })
hl(0, "DiagnosticWarn", { fg = colors.tertiary })
hl(0, "DiagnosticInfo", { fg = colors.primary })
hl(0, "DiagnosticHint", { fg = colors.secondary })
hl(0, "DiagnosticOk", { fg = colors.tertiary })
hl(0, "DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
hl(0, "DiagnosticUnderlineWarn", { sp = colors.tertiary, undercurl = true })
hl(0, "DiagnosticUnderlineInfo", { sp = colors.primary, undercurl = true })
hl(0, "DiagnosticUnderlineHint", { sp = colors.secondary, undercurl = true })
hl(0, "DiagnosticVirtualTextError", { fg = colors.error, bg = colors.error_container })
hl(0, "DiagnosticVirtualTextWarn", { fg = colors.tertiary, bg = colors.surface_low })
hl(0, "DiagnosticVirtualTextInfo", { fg = colors.primary, bg = colors.surface_low })
hl(0, "DiagnosticVirtualTextHint", { fg = colors.secondary, bg = colors.surface_low })
