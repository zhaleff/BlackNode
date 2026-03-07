local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("core.config.options")

require("lazy").setup({
  -- plugins
  -- require("core.plugins.lsplines"),
  require("core.plugins.cmp"),
  require("core.plugins.autopairs"),
  require("core.catppuccin.catppuccin"),
  -- require("core.plugins.winbar"),
  require("core.plugins.autotag"),
  require("core.plugins.bufferline"),
  require("core.plugins.nvim-tree"),
  require("core.plugins.telescope"),
  require("core.plugins.comment"),
  require("core.plugins.emmet"),
  require("core.plugins.notify"),
  require("core.plugins.blackline"),
  require("core.plugins.pets"),
  require("core.plugins.trouble"),
  require("core.plugins.dashboard"),
  require("core.plugins.navic"),
  require("core.plugins.diagnostic"),
  require("core.plugins.gitsigns"),
  require("core.plugins.tailwind_colorizer"),
  require("core.plugins.conform"),
  require("core.plugins.fidget"),
  require("core.plugins.toggleterm"),
  require("core.plugins.colorizer"),
  require("core.plugins.mason"),
  require("core.plugins.flash"),
  require("core.plugins.schemastore"),
  require("core.plugins.mason-lsp"),
  require("core.plugins.lsp"),
  require("core.plugins.mini"),
  require("core.plugins.treesiter-context"),
  require("core.plugins.winbar"),
  -- require("core.plugins.copilot"),
  require("core.plugins.which-key"),
})


require("core.config.keymaps")
require("core.config.emmet")
require("core.config.mason")
require("core.config.diagnostic")
-- require("core.plugins.winbar")
