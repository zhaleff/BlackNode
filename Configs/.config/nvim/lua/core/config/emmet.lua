vim.g.user_emmet_mode = 'i'
vim.g.user_emmet_leader_key = '<C-y>'
vim.g.user_emmet_install_global = 0
vim.g.user_emmet_complete_tag = 1

vim.g.user_emmet_settings = {
  variables = { lang = 'es' },
  indent_blockelement = 1,
  javascript = { extends = 'jsx' },
  typescript = { extends = 'tsx' },
  ['javascript.jsx'] = { extends = 'jsx' },
  ['typescript.tsx'] = { extends = 'tsx' },
  html = {
    snippets = {
      fc    = 'div.flex.items-center.justify-center|',
      fcc   = 'div.flex.items-center.justify-center.flex-col|',
      fcb   = 'div.flex.items-center.justify-between|',
      fcs   = 'div.flex.items-start.justify-start.gap-4|',
      sec   = 'section.|\n\t',
      art   = 'article.|\n\t',
      form  = '<form onSubmit={handleSubmit} className="|">\n\t\n</form>',
      inp   = '<input type="|" name="" placeholder="" className="" />',
      btn   = '<button type="button" className="|"></button>',
      divc  = '<div className="|"></div>',
      spanc = '<span className="|"></span>',
      pc    = '<p className="|"></p>',
      useS  = 'const [${1:state}, set${1/(.*)/${1:/capitalize}/}] = useState(${2:initial});|',
      useE  = 'useEffect(() => {\n\t|\n}, []);',
      useEd = 'useEffect(() => {\n\t|\n\treturn () => {};\n}, []);',
      useR  = 'const ${1:ref} = useRef(${2:null});|',
      useM  = 'const ${1:value} = useMemo(() => {\n\t|\n}, []);',
      useCb = 'const ${1:fn} = useCallback(() => {\n\t|\n}, []);',
      nav   = '<nav className="|">\n\t<ul>\n\t\t<li><a href="#">Link</a></li>\n\t</ul>\n</nav>',
      clg   = 'console.log(|);',
      clgi  = 'console.info(|);',
      clgw  = 'console.warn(|);',
      clge  = 'console.error(|);',
    },
  },
}

local emmet_ft = {
  'html', 'htmldjango', 'javascript', 'javascriptreact',
  'typescript', 'typescriptreact', 'vue', 'svelte',
  'jsx', 'tsx', 'css', 'scss', 'less', 'php', 'blade', 'xml', 'markdown',
}

local known_tags = {
  div=1, span=1, p=1, a=1, ul=1, li=1, ol=1, h1=1, h2=1, h3=1, h4=1,
  h5=1, h6=1, nav=1, header=1, footer=1, section=1, article=1, main=1,
  form=1, input=1, button=1, select=1, textarea=1, table=1, tr=1, td=1,
  th=1, img=1, video=1, audio=1, pre=1, code=1, em=1, strong=1, label=1,
  figure=1, figcaption=1, aside=1, details=1, summary=1,
}

local custom_snippets = {
  { p = 'jcb$',   r = 'justify-content: space-between;' },
  { p = 'jcc$',   r = 'justify-content: center;' },
  { p = 'jcs$',   r = 'justify-content: flex-start;' },
  { p = 'jce$',   r = 'justify-content: flex-end;' },
  { p = 'aic$',   r = 'align-items: center;' },
  { p = 'ais$',   r = 'align-items: flex-start;' },
  { p = 'aie$',   r = 'align-items: flex-end;' },
  { p = 'fdc$',   r = 'flex-direction: column;' },
  { p = 'fdr$',   r = 'flex-direction: row;' },
  { p = 'fww$',   r = 'flex-wrap: wrap;' },
  { p = 'df$',    r = 'display: flex;' },
  { p = 'dg$',    r = 'display: grid;' },
  { p = 'dib$',   r = 'display: inline-block;' },
  { p = 'db$',    r = 'display: block;' },
  { p = 'dn$',    r = 'display: none;' },
  { p = 'psa$',   r = 'position: absolute;' },
  { p = 'psr$',   r = 'position: relative;' },
  { p = 'psf$',   r = 'position: fixed;' },
  { p = 'pss$',   r = 'position: sticky;' },
  { p = 'ovh$',   r = 'overflow: hidden;' },
  { p = 'ova$',   r = 'overflow: auto;' },
  { p = 'cur$',   r = 'cursor: pointer;' },
  { p = 'usn$',   r = 'user-select: none;' },
  { p = 'ttu$',   r = 'text-transform: uppercase;' },
  { p = 'ttc$',   r = 'text-transform: capitalize;' },
  { p = 'tac$',   r = 'text-align: center;' },
  { p = 'tar$',   r = 'text-align: right;' },
  { p = 'wfull$', r = 'width: 100%;' },
  { p = 'hfull$', r = 'height: 100%;' },
  { p = 'gap$',   r = 'gap: 1rem;' },
  { p = 'red$',   r = 'text-red-500' },
  { p = 'blue$',  r = 'text-blue-500' },
  { p = 'green$', r = 'text-green-500' },
  { p = 'bgd$',   r = 'bg-gray-900' },
  { p = 'bgl$',   r = 'bg-gray-100' },
  { p = 'clge$',  r = 'console.error()' },
  { p = 'clgw$',  r = 'console.warn()' },
  { p = 'clgi$',  r = 'console.info()' },
  { p = 'clg$',   r = 'console.log()' },
  { p = 'ue$',    r = 'useEffect(() => {\n\t\n}, []);' },
  { p = 'us$',    r = 'useState(' },
  { p = 'ur$',    r = 'useRef(null)' },
  { p = 'um$',    r = 'useMemo(() => , [])' },
  { p = 'ucb$',   r = 'useCallback(() => , [])' },
  { p = 'uct$',   r = 'useContext(' },
  { p = 'cn$',    r = 'className=""' },
  { p = 'afn$',   r = '() => ' },
  { p = 'arr$',   r = '.map((item) => (\n\t\n))' },
  { p = 'flt$',   r = '.filter((item) => )' },
  { p = 'rdc$',   r = '.reduce((acc, item) => , )' },
  { p = 'imp$',   r = "import  from ''" },
  { p = 'impd$',  r = "import {  } from ''" },
  { p = 'ex$',    r = 'export default ' },
  { p = 'exn$',   r = 'export const ' },
  { p = 'ret$',   r = 'return ' },
  { p = 'aw$',    r = 'await ' },
  { p = 'try$',   r = 'try {\n\t\n} catch (err) {\n\tconsole.error(err);\n}' },
}

local function in_comment_or_string()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then return false end
  local t = node:type()
  return t == 'comment' or t == 'string' or t == 'string_content'
    or t == 'comment_content' or t == 'template_string' or t == 'jsx_text'
end

local function before_cursor()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return vim.api.nvim_get_current_line():sub(1, col)
end

local function looks_like_emmet(abbr)
  if not abbr or #abbr < 2 then return false end
  if not abbr:match('^[%a%.#]') then return false end
  if abbr:match('^[%a][%w%-]*$') then
    return known_tags[abbr] ~= nil
  end
  return abbr:match('[%.#>%+%*%^%[%]{}]') ~= nil
end

local function smart_tab()
  if vim.snippet.active({ direction = 1 }) then
    vim.schedule(function() vim.snippet.jump(1) end)
    return ''
  end

  if in_comment_or_string() then
    return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
  end

  local before = before_cursor()

  for _, c in ipairs(custom_snippets) do
    if before:match(c.p) then
      local row   = vim.api.nvim_win_get_cursor(0)[1]
      local col   = vim.api.nvim_win_get_cursor(0)[2]
      local after = vim.api.nvim_get_current_line():sub(col + 1)
      local new   = before:gsub(c.p, c.r)
      if new:find('\n') then
        local lines = vim.split(new .. after, '\n', { plain = true })
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
        vim.api.nvim_win_set_cursor(0, { row, #lines[1] })
      else
        vim.api.nvim_set_current_line(new .. after)
        vim.api.nvim_win_set_cursor(0, { row, #new })
      end
      return ''
    end
  end

  local abbr = before:match('[%w%-%.:#>%+%*%^%!%$@_%(%)%[%]{}]+$')
  if looks_like_emmet(abbr) then
    return vim.api.nvim_replace_termcodes('<C-y>,', true, true, true)
  end

  return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
end

local function smart_shift_tab()
  if vim.snippet.active({ direction = -1 }) then
    vim.schedule(function() vim.snippet.jump(-1) end)
    return ''
  end
  return vim.api.nvim_replace_termcodes('<C-d>', true, true, true)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = emmet_ft,
  callback = function()
    vim.cmd('EmmetInstall')
    vim.b.emmet_html = 1

    local buf  = { buffer = true, silent = true }
    local expr = { buffer = true, silent = true, expr = true }

    vim.keymap.set('i', '<C-y>,', '<Plug>(emmet-expand-abbr)',         buf)
    vim.keymap.set('i', '<C-y>.', '<Plug>(emmet-expand-abbr)',         buf)
    vim.keymap.set('i', '<C-y>n', '<Plug>(emmet-move-next)',           buf)
    vim.keymap.set('i', '<C-y>N', '<Plug>(emmet-move-prev)',           buf)
    vim.keymap.set('i', '<C-y>;', '<Plug>(emmet-expand-word)',         buf)
    vim.keymap.set('i', '<C-y>u', '<Plug>(emmet-update-tag)',          buf)
    vim.keymap.set('i', '<C-y>/', '<Plug>(emmet-toggle-comment)',      buf)
    vim.keymap.set('i', '<C-y>d', '<Plug>(emmet-balance-tag-outward)', buf)
    vim.keymap.set('i', '<C-y>D', '<Plug>(emmet-balance-tag-inward)',  buf)
    vim.keymap.set('n', '<C-y>,', '<Plug>(emmet-expand-abbr)',         buf)
    vim.keymap.set('n', '<C-y>/', '<Plug>(emmet-toggle-comment)',      buf)
    vim.keymap.set('n', '<C-y>d', '<Plug>(emmet-balance-tag-outward)', buf)

    vim.keymap.set('i', '<Tab>',   smart_tab,       expr)
    vim.keymap.set('i', '<S-Tab>', smart_shift_tab, expr)
  end,
})

vim.api.nvim_create_user_command('EmmetStatus', function()
  vim.print({
    filetype  = vim.bo.filetype,
    supported = vim.tbl_contains(emmet_ft, vim.bo.filetype),
    installed = vim.b.emmet_html == 1,
  })
end, {})
