-- 
--  d8b       d8b                   d8b                               d8b        
--  ?88       88P                   ?88                               88P        
--   88b     d88                     88b                             d88         
--   888888b 888   d888b8b   d8888b  888  d88'  88bd88b  d8888b  d888888   d8888b
--   88P `?8b?88  d8P' ?88  d8P' `P  888bd8P'   88P' ?8bd8P' ?88d8P' ?88  d8b_,dP
--  d88,  d88 88b 88b  ,88b 88b     d88888b    d88   88P88b  d8888b  ,88b 88b    
-- d88'`?88P'  88b`?88P'`88b`?888P'd88' `?88b,d88'   88b`?8888P'`?88P'`88b`?888P'
--
-- ## hyprland for BlackNode dotfiles
-- Creator: Zhaleff
-- Repository: https://github.com/zhaleff/BlackNode
-- BlackNode config hyprland 
-- path: ~/.config/hypr/hyprland.lua
-- Licence: MIT
--

-- Keybinds
require("settings/keybinds")

-- device 
require("settings/device")

-- monitor
require("settings/monitor")

-- gesture
require("settings/gesture")

-- Master Layout
require("settings/master-layout")

-- Scrolling Layout
require("settings/scrolling-layout")

-- Misc
require("settings/misc")

-- dwindle
require("settings/dwindle")

-- Auto Start
require("settings/autostart")

-- input
require("settings/input")

-- general 
require("settings/general")

-- decoration
require("settings/decoration")

-- animation
require("animations/vertical")

-- colors
require("themes/colors")
      
-- Windows rules
require("settings/rules")

  -- env
require("settings/env")

-- runtime overrides (from config-hud)
pcall(require, "settings/overrides")

-- Active profile (from profiles/.active)
local profile_file = io.open(os.getenv("HOME") .. "/.config/hypr/profiles/.active", "r")
if profile_file then
    local profile_name = profile_file:read("*l"):gsub("%s+", "")
    profile_file:close()
    if profile_name and #profile_name > 0 then
        pcall(require, "profiles/" .. profile_name)
    end
end

