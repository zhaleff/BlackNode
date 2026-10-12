--  d8b                         d8b        d8,      d8b
--  ?88                         ?88       `8P       88P
--   88b                         88b               d88
--   888  d88' d8888b?88   d8P   888888b   88b d888888    88bd88b  .d888b,
--   888bd8P' d8b_,dPd88   88    88P `?8b  88Pd8P' ?88    88P' ?8b ?8b,
--  d88888b   88b    ?8(  d88   d88,  d88 d88 88b  ,88b  d88   88P   `?8b
-- d88' `?88b,`?888P'`?88P'?8b d88'`?88P'd88' `?88P'`88bd88'   88b`?888P'
--                          )88
--                         ,d8P
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

local mainMod = "SUPER"
local rofi = "~/.config/rofi/scripts/"
local waybar = "~/.config/waybar/Scripts/launcher/"
local osd = "~/BlackNode/Configs/.local/bin/system/osd/"
local step = 40

local function bind(keys, action, opts)
    hl.bind(mainMod .. " + " .. keys, action, opts)
end

local function exec(cmd)
    return hl.dsp.exec_cmd(cmd)
end

-- apps and scripts
local launchers = {
    { "B", "firefox" },
    { "D", "kitty" },
    { "E", "dolphin" },
    { "Y", "spotify" },
    { "R", "rofi -show drun" },
    { "SPACE", "bash " .. rofi .. "launcher.sh" },
    { "X", rofi .. "powermenu.sh" },
    { "G", rofi .. "recordscreen.sh" },
    { "W", rofi .. "wallselect.sh" },
    { "V", rofi .. "clipboard.sh" },
    { "M", rofi .. "musicPlayer.sh" },
    { "ESCAPE", "hyprlock" },
    { "SHIFT + S", rofi .. "screenshots.sh" },
    { "SHIFT + R", rofi .. "wf-recorder.sh" },
    { "SHIFT + A", "pavucontrol" },
    { "SHIFT + X", "wlogout -b 6" },
    { "CTRL + ALT + UP", waybar .. "launch.sh" },
    { "CTRL + ALT + DOWN", waybar .. "script.sh" },
}

for _, l in ipairs(launchers) do
    bind(l[1], exec(l[2]))
end

-- window
bind("Q", hl.dsp.window.close())
bind("F", hl.dsp.window.float({ action = "toggle" }))
bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind("P", hl.dsp.window.pseudo())

-- hjkl motion
local motion = {
    h = { name = "left",  dx = -step, dy = 0 },
    j = { name = "down",  dx = 0,     dy = step },
    k = { name = "up",    dx = 0,     dy = -step },
    l = { name = "right", dx = step,  dy = 0 },
}

for key, m in pairs(motion) do
    -- focus
    bind(key, hl.dsp.focus({ direction = m.name }))
    -- move tiled window
    bind("SHIFT + " .. key, hl.dsp.window.move({ direction = m.name }))
    -- resize floating
    bind("ALT + " .. key, hl.dsp.window.resize({ x = m.dx, y = m.dy, relative = true }), { repeating = true })
    -- move floating
    bind("CTRL + " .. key, hl.dsp.window.move({ x = m.dx, y = m.dy, relative = true }), { repeating = true })
end

-- columns (scrolling)
bind("CTRL + SHIFT + h", hl.dsp.layout("swapcol l"))
bind("CTRL + SHIFT + l", hl.dsp.layout("swapcol r"))
bind("period", hl.dsp.layout("move +col"))
bind("comma", hl.dsp.layout("move -col"))
bind("minus", hl.dsp.layout("colresize -0.1"))
bind("equal", hl.dsp.layout("colresize +0.1"))
bind("A", hl.dsp.layout("promote"))
bind("T", hl.dsp.layout("togglefit"))
bind("C", hl.dsp.layout("fit active"))
bind("SHIFT + C", hl.dsp.layout("fit visible"))
bind("Home", hl.dsp.layout("fit tobeg"))
bind("End", hl.dsp.layout("fit toend"))

-- workspaces
for i = 1, 9 do
    bind(i, hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

bind("bracketright", hl.dsp.focus({ workspace = "e+1" }))
bind("bracketleft", hl.dsp.focus({ workspace = "e-1" }))
bind("SHIFT + bracketright", hl.dsp.window.move({ workspace = "e+1" }))
bind("SHIFT + bracketleft", hl.dsp.window.move({ workspace = "e-1" }))
bind("TAB", hl.dsp.focus({ workspace = "previous" }))

-- scratchpad
bind("S", hl.dsp.workspace.toggle_special("magic"))
bind("ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- mouse
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))
bind("SHIFT + mouse_down", hl.dsp.layout("move +col"))
bind("SHIFT + mouse_up", hl.dsp.layout("move -col"))
bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- media keys
local media = {
    { "XF86AudioNext", "playerctl next" },
    { "XF86AudioPrev", "playerctl previous" },
    { "XF86AudioPlay", "playerctl play-pause" },
    { "XF86AudioPause", "playerctl play-pause" },
    { "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && " .. osd .. "audio.sh" },
}

for _, m in ipairs(media) do
    hl.bind(m[1], exec(m[2]), { locked = true })
end

-- volume and brightness (held)
local held = {
    { "XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && " .. osd .. "audio.sh" },
    { "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && " .. osd .. "audio.sh" },
    { "XF86MonBrightnessUp", "brightnessctl -e4 -n2 set 5%+ && " .. osd .. "brightness.sh" },
    { "XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%- && " .. osd .. "brightness.sh" },
}

for _, h in ipairs(held) do
    hl.bind(h[1], exec(h[2]), { locked = true, repeating = true })
end
