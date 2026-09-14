local colors = require("core.highlights.colors")

local hl = vim.api.nvim_set_hl

local groups = {
  ["@variable"] = { fg = colors.fg },
  ["@variable.builtin"] = { fg = colors.secondary, italic = true },
  ["@variable.parameter"] = { fg = colors.on_surface_variant },
  ["@variable.parameter.builtin"] = { fg = colors.secondary },
  ["@variable.member"] = { fg = colors.primary },

  ["@constant"] = { fg = colors.secondary },
  ["@constant.builtin"] = { fg = colors.secondary, bold = true },
  ["@constant.macro"] = { fg = colors.secondary },

  ["@module"] = { fg = colors.primary },
  ["@module.builtin"] = { fg = colors.primary },
  ["@namespace"] = { fg = colors.primary },
  ["@label"] = { fg = colors.secondary },

  ["@string"] = { fg = colors.tertiary },
  ["@string.documentation"] = { fg = colors.outline, italic = true },
  ["@string.regexp"] = { fg = colors.tertiary_container },
  ["@string.escape"] = { fg = colors.tertiary_container, bold = true },
  ["@string.special"] = { fg = colors.tertiary_container },
  ["@string.special.symbol"] = { fg = colors.secondary },
  ["@string.special.url"] = { fg = colors.primary, underline = true },
  ["@character"] = { fg = colors.tertiary },
  ["@character.special"] = { fg = colors.tertiary_container },

  ["@number"] = { fg = colors.secondary },
  ["@number.float"] = { fg = colors.secondary },
  ["@boolean"] = { fg = colors.secondary, bold = true },

  ["@function"] = { fg = colors.primary },
  ["@function.builtin"] = { fg = colors.primary, italic = true },
  ["@function.call"] = { fg = colors.primary },
  ["@function.macro"] = { fg = colors.primary },
  ["@function.method"] = { fg = colors.primary },
  ["@function.method.call"] = { fg = colors.primary },
  ["@method"] = { fg = colors.primary },
  ["@method.call"] = { fg = colors.primary },
  ["@constructor"] = { fg = colors.primary_container, bold = true },
  ["@parameter"] = { fg = colors.on_surface_variant },

  ["@operator"] = { fg = colors.on_surface_variant },

  ["@keyword"] = { fg = colors.secondary },
  ["@keyword.function"] = { fg = colors.secondary },
  ["@keyword.operator"] = { fg = colors.secondary },
  ["@keyword.return"] = { fg = colors.secondary, bold = true },
  ["@keyword.import"] = { fg = colors.primary },
  ["@keyword.repeat"] = { fg = colors.secondary },
  ["@keyword.conditional"] = { fg = colors.secondary },
  ["@keyword.exception"] = { fg = colors.secondary },
  ["@keyword.coroutine"] = { fg = colors.secondary },
  ["@keyword.type"] = { fg = colors.secondary },
  ["@keyword.modifier"] = { fg = colors.secondary },
  ["@keyword.directive"] = { fg = colors.primary },

  ["@punctuation.delimiter"] = { fg = colors.on_surface_variant },
  ["@punctuation.bracket"] = { fg = colors.on_surface_variant },
  ["@punctuation.special"] = { fg = colors.tertiary },

  ["@comment"] = { fg = colors.outline, italic = true },
  ["@comment.documentation"] = { fg = colors.outline, italic = true },
  ["@comment.error"] = { fg = colors.error },
  ["@comment.warning"] = { fg = colors.tertiary },
  ["@comment.todo"] = { fg = colors.on_tertiary_container, bg = colors.tertiary_container, bold = true },
  ["@comment.note"] = { fg = colors.on_primary_container, bg = colors.primary_container },

  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { underline = true },
  ["@markup.heading"] = { fg = colors.primary, bold = true },
  ["@markup.link"] = { fg = colors.primary, underline = true },
  ["@markup.link.url"] = { fg = colors.primary, underline = true },
  ["@markup.link.label"] = { fg = colors.secondary },
  ["@markup.raw"] = { fg = colors.tertiary },
  ["@markup.list"] = { fg = colors.secondary },
  ["@markup.quote"] = { fg = colors.outline, italic = true },

  ["@type"] = { fg = colors.primary_container },
  ["@type.builtin"] = { fg = colors.primary_container, italic = true },
  ["@type.definition"] = { fg = colors.primary_container },
  ["@attribute"] = { fg = colors.secondary },
  ["@property"] = { fg = colors.primary },
  ["@field"] = { fg = colors.primary },

  ["@tag"] = { fg = colors.primary },
  ["@tag.builtin"] = { fg = colors.primary },
  ["@tag.attribute"] = { fg = colors.secondary },
  ["@tag.delimiter"] = { fg = colors.outline },

  ["@diff.plus"] = { fg = colors.tertiary },
  ["@diff.minus"] = { fg = colors.error },
  ["@diff.delta"] = { fg = colors.secondary },

  -- LSP semantic tokens
  ["@lsp.type.class"] = { fg = colors.primary_container },
  ["@lsp.type.decorator"] = { fg = colors.secondary },
  ["@lsp.type.enum"] = { fg = colors.primary_container },
  ["@lsp.type.enumMember"] = { fg = colors.secondary },
  ["@lsp.type.function"] = { fg = colors.primary },
  ["@lsp.type.interface"] = { fg = colors.primary_container },
  ["@lsp.type.macro"] = { fg = colors.primary },
  ["@lsp.type.method"] = { fg = colors.primary },
  ["@lsp.type.namespace"] = { fg = colors.primary },
  ["@lsp.type.parameter"] = { fg = colors.on_surface_variant },
  ["@lsp.type.property"] = { fg = colors.primary },
  ["@lsp.type.struct"] = { fg = colors.primary_container },
  ["@lsp.type.type"] = { fg = colors.primary_container },
  ["@lsp.type.typeParameter"] = { fg = colors.primary_container },
  ["@lsp.type.variable"] = { fg = colors.fg },
}

for group, opts in pairs(groups) do
  hl(0, group, opts)
end
