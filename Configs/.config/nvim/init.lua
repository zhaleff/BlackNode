local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("core.config.options")
-- require("core.config.explorer")


require("lazy").setup({
  -- plugins
  require("core.plugins.cmp"),
  require("core.plugins.autopairs"),
  require("core.plugins.fzf"),
  require("core.plugins.autotag"),
  require("core.plugins.bufferline"),
  require("core.plugins.conform"),
  require("core.plugins.mason"),
  require("core.plugins.lualine"),
  require("core.plugins.mason-lsp"),
  require("core.plugins.luasnip"),
  require("core.plugins.oil"),
  require("core.plugins.lsp"),
})

require("core.config.keymaps")

vim.o.termguicolors = true
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

require("core.highlights.core")
require("core.highlights.treesitter")
require("core.highlights.diagnostics")
require("core.highlights.cmp")
require("core.highlights.oil")
