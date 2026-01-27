-- core/plugins/winbar.lua
return {
  "fgheng/winbar.nvim",
  event = "BufWinEnter",
  opts = {
    enabled = true,
    show_file_path = true,   -- muestra la ruta del archivo
    show_symbols = true,     -- permite combinar con treesitter-context
    file_path = "relative",  -- "absolute" si quieres la ruta completa
    separator = " -> ",      -- tu flecha
    symbols = {
      -- aquí puedes mapear símbolos de treesitter si quieres
      File = " ",
      Module = " ",
      Namespace = " ",
      Class = " ",
      Method = " ",
      Function = " ",
      Constructor = " ",
      Field = " ",
      Property = " ",
      Enum = "",
      Interface = "",
      Variable = "",
      Constant = "",
      String = "",
      Number = "#",
      Boolean = "",
      Array = "",
      Object = "",
      Key = "",
      Null = "",
      EnumMember = "",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",
    },
  },
}

