--  d8b                         d8b        d8,      d8b                   
--  ?88                         ?88       `8P       88P                   
--   88b                         88b               d88                    
--   888  d88' d8888b?88   d8P   888888b   88b d888888    88bd88b  .d888b,
--   888bd8P' d8b_,dPd88   88    88P `?8b  88Pd8P' ?88    88P' ?8b ?8b,   
--  d88888b   88b    ?8(  d88   d88,  d88 d88 88b  ,88b  d88   88P   `?8b 
-- d88' `?88b,`?888P'`?88P'?8b d88'`?88P'd88' `?88P'`88bd88'   88b`?888P' 
--                          )88                                           
--                         ,d8P                                           
--                       ?888P'                                           

-- keybinds.lua
-- Creator : zhaleff
-- Repository : https://github.com/zhaleff/BlackNode
-- Description: Hyprland keybindings configuration via hl (hyprland-lua)

local mainMod = "SUPER"


-- Focus movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))


-- Applications
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("spotify"))


-- Launchers and menus
hl.bind(mainMod .. " + R",     hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("~/.local/bin/bn-menu"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.config/rofi/launcher/launcher.sh"))
hl.bind(" + CTRL + ALT + UP", hl.dsp.exec_cmd("~/.config/waybar/Scripts/launcher/launch.sh"))
hl.bind(mainMod .. " + T",     hl.dsp.exec_cmd("~/.config/rofi/scripts/musicPlayer.sh"))
hl.bind(mainMod .. " + A",     hl.dsp.exec_cmd("~/.config/rofi/scripts/wifi.sh"))
hl.bind(mainMod .. " + SHIFT + X",     hl.dsp.exec_cmd("~/.config/rofi/scripts/powermenu.sh"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.config/rofi/scripts/bookmarks.sh"))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("~/.config/rofi/scripts/battery.sh"))

-- Clipboard
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("kitty --class clipse -e clipse"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("~/.config/rofi/scripts/clipboard.sh"))


-- Screenshots and recording
hl.bind(mainMod .. " + H",         hl.dsp.exec_cmd("~/.config/rofi/scripts/hyprshot.sh"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("~/.config/rofi/scripts/wf-recorder.sh"))
          

-- System
-- hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker")
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("wlogout -b 6"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprpicker"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
-- Wallpaper, animations and audio settings
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("~/.config/rofi/scripts/wallselect.sh"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("~/.config/rofi/scripts/themeselect.sh"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("pavucontrol"))


-- Waybar launcher
hl.bind(mainMod .. " + CTRL + ALT + up", hl.dsp.exec_cmd("~/.config/waybar/Scripts/launcher/script.sh"))


-- Workspaces 1-9: focus and move window
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end


-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))


-- Mouse: scroll to switch workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse: drag and resize windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- Media keys (work on lock screen)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })

hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && ~/.local/bin/brightness.sh"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && ~/.local/bin/brightness.sh"), { locked = true, repeating = true })



-- Volume (repeating, works on lock screen)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && ~/.local/bin/volume.sh"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ~/.local/bin/volume.sh"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("~/.local/bin/mute.sh"), { locked = true, repeating = true })
