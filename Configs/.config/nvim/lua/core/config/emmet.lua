vim.g.user_emmet_mode = 'i'
vim.g.user_emmet_leader_key = '<C-y>'
vim.g.user_emmet_install_global = 0
vim.g.user_emmet_complete_tag = 1
vim.g.user_emmet_settings = {
  variables = { lang = "es" },
  indent_blockelement = 1,
  javascript = { extends = 'jsx' },
  typescript = { extends = 'tsx' },
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

local emmet_ft = {
  "html", "htmldjango", "javascript", "javascriptreact",
  "typescript", "typescriptreact", "vue", "svelte",
  "jsx", "tsx", "css", "scss", "less", "php", "blade", "xml", "markdown"
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = emmet_ft,
  callback = function()
    vim.cmd('EmmetInstall')
    vim.b.emmet_html = 1
  end,
})

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

local function in_comment_or_string()
  local ok, ts = pcall(vim.treesitter.get_node)
  if not ok then return false end
  local node = ts()
  if not node then return false end
  local type = node:type()
  return type == "comment" or type == "string" or type == "string_content" or type == "comment_content"
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = emmet_ft,
  callback = function()
    vim.keymap.set('i', '<Tab>', function()
      if vim.snippet and vim.snippet.active({ direction = 1 }) then
        vim.schedule(function() vim.snippet.jump(1) end)
        return ""
      end

      if in_comment_or_string() then
        return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
      end

      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before = line:sub(1, col + 1)

      local emmet_pattern = "[%w%-%.:#>%+%*%^%!%$@_%(%)%[%]]+$"
      local abbr = before:match(emmet_pattern)
      if abbr and #abbr >= 2 then
        if abbr:match("^[%w%.#]") or abbr:match("[>+%*%^]") then
          return vim.api.nvim_replace_termcodes("<C-y>,", true, true, true)
        end
      end

      local customs = {
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
        { p = "red$",  r = "text-red-500" },
        { p = "blue$", r = "text-blue-500" },
        { p = "bgd$",  r = "bg-gray-900" },
        { p = "bgl$",  r = "bg-gray-100" },
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

      return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
    end, { expr = true, buffer = true, desc = "Smart Tab" })

    vim.keymap.set('i', '<S-Tab>', function()
      if vim.snippet and vim.snippet.active({ direction = -1 }) then
        vim.schedule(function() vim.snippet.jump(-1) end)
        return ""
      end
      return vim.api.nvim_replace_termcodes("<C-d>", true, true, true)
    end, { expr = true, buffer = true, desc = "Snippet prev or dedent" })
  end,
})

vim.api.nvim_create_user_command('EmmetStatus', function()
  print("Emmet active:", vim.b.emmet_html and "yes" or "no")
  print("Filetype:", vim.bo.filetype)
end, {})
