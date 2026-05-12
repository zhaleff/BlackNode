--[[
                   d8b                
                   88P                
                  d88                 
  88bd88b?88   d8P888   d8888b .d888b,
  88P'  `d88   88 ?88  d8b_,dP ?8b,   
 d88     ?8(  d88  88b 88b       `?8b 
d88'     `?88P'?8b  88b`?888P'`?888P' 

--]]


hl.window_rule({
  name = "windowrule-1",
  float = true,
  size = "622 625",
  stay_focused = true,
  match = { class = "clipse" },
})

hl.window_rule({
  name = "windowrule-2",
  float = true,
  size = "800 600",
  match = { class = "imv" },
})

hl.window_rule({
  name = "windowrule-3",
  float = false,
  opacity = "0.8",
  match = { class = "kitty" },
})

hl.window_rule({
  name = "windowrule-4",
  float = false,
  match = { class = "firefox" },
})

hl.window_rule({
  name = "windowrule-5",
  float = false,
  opacity = "0.8",
  match = { class = "Alacritty" },
})

hl.window_rule({
  name = "windowrule-6",
  size = "800 600",
  center = true,
  float = true,
  match = { class = "org.kde.dolphin" },
})

hl.window_rule({
  name = "windowrule-7",
  float = false,
  opacity = "0.8",
  match = { class = "spotify" },
})
hl.window_rule({
  name = "windowrule-8",
  float = true,
  size = "700 500",
  center = true,
  match = { class = "org.gnome.Shotwell" },
})

hl.window_rule({
  name = "windowrule-9",
  float = true,
  size = "800 600",
  match = { class = "org.pulseaudio.pavucontrol" },
})
hl.window_rule({
  name = "windowrule-10",
  float = true,
  size = "800 600",
  match = { class = "org.kde.filelight" },
})

hl.window_rule({
  name = "windowrule-11",
  float = true,
  size = "800 600",
  match = { class = "org.gnome.cheese" },
})
hl.window_rule({
  name = "windowrule-12",
  float = true,
  size = "800 600",
  opacity = "0.75",
  match = { class = "thunar"}
})
hl.window_rule({
  name = "windowrule-13",
  float = true,
  size = "800 600",
  center = true,
  match = { class = "nwg-look" }
})
hl.window_rule({
  name = "windowrule-14",
  float = true,
  size = "800 600",
  center = true,
  match = { class = "nemo" }
})

hl.window_rule({
  name = "windowrule-15",
  float = false,
  center = true,
  size = "670 670",
  match = { class = "xdg-desktop-portal-gtk" }
})
-- rules layerrule

hl.layer_rule({
  name = "layerrule-1",
  blur = true,
  ignore_alpha = 0,
  match = { namespace = "kitty" },
})
hl.layer_rule({
  name = "layerrule-2",
  blur = true,
  ignore_alpha = 0,
  no_anim = true,
  match = { namespace = "logout_dialog" },
})
hl.layer_rule({
  name = "layerrule-3",
  blur = true,
  ignore_alpha = 0,
  match = { namespace = "waybar" },
})
hl.layer_rule({
  name = "layerrule-4",
  blur = true,
  ignore_alpha = 0,
  match = { namespace = "rofi" },
})

hl.layer_rule({
  name = "layerrule-5",
  no_anim = true,
  match = { namespace = "selection" },
})
hl.layer_rule({
  name = "layerrule-6",
  blur = true,
  ignore_alpha = 0,
  match = { namespace = "Alacritty" },
})
hl.layer_rule({
  name = "layerrule-7",
  no_anim = true,
  match = { namespace = "hyprpicker" },
})
