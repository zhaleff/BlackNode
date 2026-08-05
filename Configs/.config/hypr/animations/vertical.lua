-- project: blacknode dotfiles
-- file: animations/vertical.lua
-- description: hyprland v0.55 animation config

hl.curve("standard",          { type = "bezier", points = { {0.2, 0.0}, {0.0, 1.0} } })
hl.curve("emphasized",        { type = "bezier", points = { {0.05, 0.7}, {0.1, 1.0} } })
hl.curve("emphasizedAccel",   { type = "bezier", points = { {0.3, 0.0}, {0.8, 0.15} } })
hl.curve("smoothOut",         { type = "bezier", points = { {0.16, 1.0}, {0.3, 1.0} } })
hl.curve("workspaceBounce",   { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.08} } })
hl.curve("layerBounce",       { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.08} } })
hl.curve("linear",            { type = "bezier", points = { {1, 1}, {1, 1} } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",     enabled = true, speed = 4,  bezier = "standard",        style = "slidevert" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4,  bezier = "emphasized",       style = "slidevert right" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3,  bezier = "emphasizedAccel",  style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,  bezier = "standard",         style = "slide" })

hl.animation({ leaf = "layersIn",    enabled = true, speed = 6,  bezier = "layerBounce",      style = "slidevert" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3,  bezier = "emphasizedAccel",  style = "slidevert" })
hl.animation({ leaf = "layers",      enabled = true, speed = 4,  bezier = "emphasized",       style = "slidevert" })

hl.animation({ leaf = "fadeIn",      enabled = true, speed = 7,  bezier = "standard" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 6,  bezier = "smoothOut" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 7,  bezier = "standard" })
hl.animation({ leaf = "fadeShadow",  enabled = true, speed = 7,  bezier = "standard" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 6,  bezier = "smoothOut" })
hl.animation({ leaf = "fadeLayers",  enabled = true, speed = 6,  bezier = "standard" })

hl.animation({ leaf = "workspaces",  enabled = true, speed = 7,  bezier = "workspaceBounce",  style = "slidevert" })

hl.animation({ leaf = "border",      enabled = true, speed = 2,  bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 20, bezier = "linear", style = "loop" })

hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
