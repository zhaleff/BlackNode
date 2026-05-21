-- ~/.config/matugen/templates/nvim.lua
return {
  colors = {
    comment = "{{colors.outline.default.hex}}",
    delimiter = "{{colors.outline.default.hex}}",
    operator = "{{colors.primary.default.hex}}",
    todo = "{{colors.secondary.default.hex}}",
    identifier = "{{colors.primary.default.hex}}",
    constant = "{{colors.tertiary.default.hex}}",
    type = "{{colors.secondary.default.hex}}",
    string = "{{colors.tertiary.default.hex}}",
    special = "{{colors.secondary.default.hex}}",
    preproc = "{{colors.secondary.default.hex}}",
    function_name = "{{colors.primary.default.hex}}",
    statement = "{{colors.primary.default.hex}}",
    error_bg = "{{colors.error.default.hex}}",
    error_fg = "{{colors.on_error.default.hex}}",
    status_bg = "{{colors.primary.default.hex}}",
    status_fg = "{{colors.on_primary.default.hex}}",
    status_nc_bg = "{{colors.surface_variant.default.hex}}",
    status_nc_fg = "{{colors.on_surface_variant.default.hex}}",
    visual_bg = "{{colors.primary_container.default.hex}}",
    normal_bg = "{{colors.background.default.hex}}",
    normal_fg = "{{colors.on_background.default.hex}}"
  }
}
