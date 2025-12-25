-- === EMMET ===
vim.g.user_emmet_mode = 'a'
vim.g.user_emmet_leader_key = '<C-y>'
vim.g.user_emmet_install_global = 1
vim.g.user_emmet_complete_tag = 1
vim.g.user_emmet_expandabbr_key = '<C-y>,'

vim.g.user_emmet_settings = {
  variables = {
    lang = "es"
  },
  indent_blockelement = 1,
  javascript = {
    extends = 'jsx'
  },
  typescript = {
    extends = 'tsx'
  }
}

-- Activar Emmet para todos los tipos de archivo relevantes
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "html", "htmldjango", "javascript", "javascriptreact", 
    "typescript", "typescriptreact", "vue", "svelte",
    "jsx", "tsx", "css", "scss", "less", "php", "blade"
  },
  callback = function()
    vim.cmd('EmmetInstall')
    vim.b.emmet_html = 1
  end
})

-- Mapeos simplificados y confiables
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "html", "htmldjango", "javascript", "javascriptreact", 
    "typescript", "typescriptreact", "vue", "svelte",
    "jsx", "tsx"
  },
  callback = function()
    -- Mapeo principal para expandir abreviatura
    vim.keymap.set('i', '<C-y>,', '<Plug>(emmet-expand-abbr)', { 
      buffer = true, 
      desc = 'Emmet: Expand abbreviation' 
    })
    
    -- Mapeo alternativo con Enter
    vim.keymap.set('i', '<C-y><CR>', '<Plug>(emmet-expand-abbr)', { 
      buffer = true, 
      desc = 'Emmet: Expand abbreviation' 
    })
    
    -- Mapeo para siguiente punto de edición
    vim.keymap.set('i', '<C-y>n', '<Plug>(emmet-move-next)', { 
      buffer = true, 
      desc = 'Emmet: Next edit point' 
    })
    
    -- Mapeo para anterior punto de edición
    vim.keymap.set('i', '<C-y>N', '<Plug>(emmet-move-prev)', { 
      buffer = true, 
      desc = 'Emmet: Previous edit point' 
    })
    
    -- Mapeo inteligente con Tab
    vim.keymap.set('i', '<Tab>', function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before_cursor = line:sub(1, col)
      
      -- Detectar si estamos después de una abreviatura de Emmet
      if before_cursor:match("[%w%->!%[%]%+%*%(%)#%.%%$@_]+$") then
        local word = before_cursor:match("([%w%->!%[%]%+%*%(%)#%.%%$@_]+)$")
        if word and (word:match("^%a+%d*$") or word:match("^%.%a+") or word:match("^#%a+")) then
          return '<C-y>,'
        end
      end
      return '<Tab>'
    end, { expr = true, buffer = true, desc = 'Emmet expand or Tab' })
  end
})

-- Comando para verificar estado de Emmet
vim.api.nvim_create_user_command('EmmetStatus', function()
  print('Emmet global installed:', vim.g.user_emmet_install_global)
  print('Emmet leader key:', vim.g.user_emmet_leader_key)
  print('Current filetype:', vim.bo.filetype)
  print('Emmet active for buffer:', vim.b.emmet_html or 'no')
end, {})
