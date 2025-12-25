-- Copyright (c) 2025 Zhaleff && HollowSec. All Rights Reserved.
-- Licence: MIT 
-- Repository: https://github.com/zhaleff/BlackNode/
--
-- Creator: ? 
-- HollowSec && Zhaleff, 
-- Directory: ~/.config/nvim/  
-- Plugins: ~/.config/nvim/lua/core/themes
-- Themes: ~/.config/nvim/lua/core/themes 

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("core.config.options") --[[ These are the nvim options. ]]

require("lazy").setup({  
  --
  -- this is structure of plugins. 
  -- HollowSec && Zhaleff
  -- BlackNode Nvim  
  --

  -- Here’s where you can chuck in your custom plugins. 
  -- Below is the layout for plugins and themes
  -- Themes: ~/.config/nvim/lua/themes  You can drop in whatever theme you fancy here — just replace it.
  -- require("core.catppuccin.catpuccin") This is example, Use whatever one you like. 
  -- BlackNode comes with 5 ready-made themes to choose from. 
  -- example: require("core.themes.tokyonight")
  -- BlackNode also has its own palette, called ‘HollowColor' 
  -- 
  -- Plugins: ~/.config/nivm/lua/core/plugins/ 
  -- example: ~/.config/nvim/lua/core/plugins/lsp.lua 
  -- if u want to add, u need to do the following
  -- require - this is important. 
  -- require("core") 'core' This is the directory where the settings are located.  
  -- require("core.plugins") The 'plugins' is directory where the plugins 
  -- require("core.plugins.name-of-plugin") U cant add the one you like best 
  -- For each plugin, or Lua file you want to add, u must put 'return {'
  -- example: 
  -- return {
    --  { "neovim/nvim-lspconfig" ,
    -- }
  --
  -- plugins 
  require("core.plugins.cmp"), 
  require("core.plugins.autopairs"),
  require("core.themes.catppuccin"),
  require("core.plugins.bufferline"),
  require("core.plugins.autotag"),
  require("core.plugins.bufferline"),
  require("core.plugins.nvim-tree"),
  require("core.plugins.telescope"),
  require("core.plugins.comment"),
  require("core.plugins.emmet"),
  require("core.plugins.notify"),
  require("core.plugins.blackline"),
  require("core.plugins.trouble"),
  require("core.plugins.dashboard"),
  require("core.plugins.gitsigns"),
  require("core.plugins.mason"),
  require("core.plugins.flash"),
  require("core.plugins.mason-lsp"),
  require("core.plugins.lsp"),
  require("core.plugins.winbar"),
  -- require("core.plugins.copilot"),
  require("core.plugins.neogen"),
  require("core.plugins.which-key"),
})

-- These are the general nvim settings outside of lazy 
-- u can add your own bits here however you like.
--

require("core.config.keymaps") --[[ This?, is keymaps for nvim jej ]]
require("core.config.emmet") --[[ This is configuration for Emmet LSP html, programming web :D, for css, html, jsonc, etc ]]
require("core.config.mason") --[[  There are the configuration of mason lsp  ]]
require("core.config.diagnostic") --[[ this is the settings of diagnostic for nvim ]]
