-- project: blacknode dotfiles
-- file: animations/vertical.lua
-- description: hyprland v0.55 animation config

hl.curve("default",           { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("wind",              { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("overshot",          { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.08} } })
hl.curve("liner",             { type = "bezier", points = { {1, 1}, {1, 1} } })
hl.curve("bounce",            { type = "bezier", points = { {0.4, 0.9}, {0.6, 1.0} } })
hl.curve("snappyReturn",      { type = "bezier", points = { {0.4, 0.9}, {0.6, 1.0} } })
hl.curve("slideInFromRight",  { type = "bezier", points = { {0.5, 0.0}, {0.5, 1.0} } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",     enabled = true, speed = 5,  bezier = "snappyReturn", style = "slidevert" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5,  bezier = "snappyReturn", style = "slidevert right" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5,  bezier = "snappyReturn", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6,  bezier = "bounce",       style = "slide" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 5,  bezier = "bounce",       style = "slidevert right" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fadeShadow",  enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fadeLayers",  enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 7,  bezier = "overshot",     style = "slidevert" })
hl.animation({ leaf = "border",      enabled = true, speed = 1,  bezier = "liner" })
hl.animation({ leaf = "layers",      enabled = true, speed = 4,  bezier = "bounce",       style = "slidevert right" })

hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
