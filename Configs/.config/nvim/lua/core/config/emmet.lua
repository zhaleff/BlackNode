

vim.g.user_emmet_mode = 'i'
vim.g.user_emmet_leader_key = '<C-y>'
vim.g.user_emmet_install_global = 0

local emmet_ft = {
  'html', 'htmldjango',
  'javascript', 'javascriptreact',
  'typescript', 'typescriptreact',
  'jsx', 'tsx',
  'vue', 'svelte',
  'css', 'scss', 'less',
  'php', 'blade',
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = emmet_ft,
  callback = function()
    vim.cmd('EmmetInstall')
    vim.keymap.set('i', '<C-y>,', '<Plug>(emmet-expand-abbr)', { buffer = true, silent = true })
  end,
})
