-- === EMMET VIM MEJORADO 2026 (clásico pero ULTRA-INTELIGENTE y EFICIENTE) ===
-- Versión pulida al máximo: más precisa, rápida y con Tree-sitter para contexto
-- Mantiene TODOS tus mapeos originales <C-y>...
-- <Tab> ahora es aún más listo: detecta Emmet + snippets + customs + Tree-sitter context
-- No expande Emmet dentro de strings/comments (gracias a Tree-sitter)

vim.g.user_emmet_mode = 'i'         -- solo insert mode (seguro y rápido)
vim.g.user_emmet_leader_key = '<C-y>'
vim.g.user_emmet_install_global = 0 -- control manual por buffer
vim.g.user_emmet_complete_tag = 1
vim.g.user_emmet_settings = {
  variables = { lang = "es" },
  indent_blockelement = 1,
  javascript = { extends = 'jsx' },
  typescript = { extends = 'tsx' },
  -- Snippets personalizados rápidos (más útiles y comunes)
  html = {
    snippets = {
      fc = "div.flex.items-center.justify-center|",
      fcc = "div.flex.items-center.justify-center.flex-col|",
      fcb = "div.flex.items-center.justify-between|",
      clg = "console.log(|);",
      useS = "const [${1:state}, set${1/(.*)/${1:/capitalize}/}] = useState(${2:initial});|",
      useE = "useEffect(() => {|}, []);",
      divc = "<div className=\"|\"></div>",
      spanc = "<span className=\"|\"></span>",
      nav = "<nav className=\"|\">\n\t<ul>\n\t\t<li><a href=\"#\">Link</a></li>\n\t</ul>\n</nav>|",
    },
  },
}

-- Filetypes donde activamos Emmet
local emmet_ft = {
  "html", "htmldjango", "javascript", "javascriptreact",
  "typescript", "typescriptreact", "vue", "svelte",
  "jsx", "tsx", "css", "scss", "less", "php", "blade", "xml", "markdown"
}

-- Activación automática
vim.api.nvim_create_autocmd("FileType", {
  pattern = emmet_ft,
  callback = function()
    vim.cmd('EmmetInstall')
    vim.b.emmet_html = 1
  end,
})

-- Mapeos clásicos <C-y>... (exactamente como los tenías)
vim.api.nvim_create_autocmd("FileType", {
  pattern = emmet_ft,
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set('i', '<C-y>,', '<Plug>(emmet-expand-abbr)', opts)
    vim.keymap.set('i', '<C-y><CR>', '<Plug>(emmet-expand-abbr)', opts)
    vim.keymap.set('i', '<C-y>n', '<Plug>(emmet-move-next)', opts)
    vim.keymap.set('i', '<C-y>N', '<Plug>(emmet-move-prev)', opts)
    vim.keymap.set('i', '<C-y>;', '<Plug>(emmet-expand-word)', opts)
    vim.keymap.set('i', '<C-y>u', '<Plug>(emmet-update-tag)', opts)
  end,
})

-- <Tab> SUPER INTELIGENTE (pulido al máximo con Tree-sitter)
vim.api.nvim_create_autocmd("FileType", {
  pattern = emmet_ft,
  callback = function()
    vim.keymap.set('i', '<Tab>', function()
      -- 1. Snippet jump primero (luasnip o vim.snippet)
      if vim.snippet.active({ direction = 1 }) then
        vim.schedule(function() vim.snippet.jump(1) end)
        return ""
      end

      -- 2. Tree-sitter context: NO expandir Emmet en comments/strings
      local ts_context = require("cmp.config.context") -- Reusamos el mismo de cmp (preciso y rápido)
      if ts_context.in_treesitter_capture("comment") or ts_context.in_treesitter_capture("string") or
          ts_context.in_syntax_group("Comment") or ts_context.in_syntax_group("String") then
        return vim.api.nvim_replace_termcodes("<Tab>", true, true, true) -- solo indent
      end

      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local before = line:sub(1, col)

      -- 3. Detectar abreviatura Emmet (regex más preciso y robusto)
      local emmet_pattern = "[%w%-%.:#>%+%*%^%!%$@_%(%)%[%]]+$"
      local abbr = before:match(emmet_pattern)
      if abbr and #abbr >= 2 then
        if abbr:match("^[%w%.#]") or abbr:match("[>%+%*%^]") then
          return vim.api.nvim_replace_termcodes("<C-y>,", true, true, true)
        end
      end

      -- 4. Patrones personales frecuentes (más útiles y comunes 2026)
      local customs = {
        -- CSS / Tailwind rápidos
        { p = "df$",   r = "display: flex;" },
        { p = "dg$",   r = "display: grid;" },
        { p = "db$",   r = "display: block;" },
        { p = "jcc$",  r = "justify-content: center;" },
        { p = "aic$",  r = "align-items: center;" },
        { p = "fdc$",  r = "flex-direction: column;" },
        { p = "fdr$",  r = "flex-direction: row;" },
        { p = "gap$",  r = "gap: 1rem;" },
        { p = "p$",    r = "padding: 1rem;" },
        { p = "m$",    r = "margin: 1rem;" },

        -- Tailwind class shortcuts (si no usas LSP full)
        { p = "red$",  r = "text-red-500" },
        { p = "blue$", r = "text-blue-500" },
        { p = "bgd$",  r = "bg-gray-900" },
        { p = "bgl$",  r = "bg-gray-100" },

        -- JS/TSX comunes
        { p = "clg$",  r = "console.log()" },
        { p = "ue$",   r = "useEffect(() => {|}, []);" },
        { p = "us$",   r = "useState(" },
        { p = "ur$",   r = "useRef(null)" },
        { p = "cn$",   r = "className=\"|\"" },
      }

      for _, c in ipairs(customs) do
        if before:match(c.p) then
          local new_line = before:gsub(c.p, c.r)
          vim.api.nvim_set_current_line(new_line)
          vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #new_line })
          return ""
        end
      end

      -- 5. Nada coincide → indent normal
      return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
    end, { expr = true, buffer = true, desc = "Smart Tab: Emmet + customs + snippet jump + TS context" })

    -- Shift-Tab para ir atrás en snippets o dedent
    vim.keymap.set('i', '<S-Tab>', function()
      if vim.snippet.active({ direction = -1 }) then
        vim.schedule(function() vim.snippet.jump(-1) end)
        return ""
      end
      return vim.api.nvim_replace_termcodes("<C-d>", true, true, true)
    end, { expr = true, buffer = true })
  end,
})

-- Comando rápido para debug
vim.api.nvim_create_user_command('EmmetStatus', function()
  print("Emmet active:", vim.b.emmet_html and "yes" or "no")
  print("Filetype:", vim.bo.filetype)
end, {})
