local colors = require("core.highlights.colors")

local hl = vim.api.nvim_set_hl

hl(0, "OilDir", { fg = colors.primary })
hl(0, "OilFile", { fg = colors.fg })
