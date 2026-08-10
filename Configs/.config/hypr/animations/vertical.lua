-- project: blacknode dotfiles
-- file: animations/vertical.lua
-- description: hyprland v0.55 animation config
-- vibe: fast, smooth, premium, subtle bounce

hl.curve("standard",          { type = "bezier", points = { {0.24, 0.00}, {0.28, 1.00} } })
hl.curve("emphasized",        { type = "bezier", points = { {0.16, 0.70}, {0.24, 1.00} } })
hl.curve("emphasizedAccel",   { type = "bezier", points = { {0.34, 0.00}, {0.72, 0.12} } })
hl.curve("smoothOut",         { type = "bezier", points = { {0.22, 0.72}, {0.32, 1.00} } })

hl.curve("windowBounce",      { type = "bezier", points = { {0.18, 0.82}, {0.30, 1.04} } })
hl.curve("layerBounce",       { type = "bezier", points = { {0.22, 0.84}, {0.34, 1.03} } })
hl.curve("workspaceBounce",   { type = "bezier", points = { {0.20, 0.86}, {0.30, 1.035} } })

hl.curve("linear",            { type = "bezier", points = { {0.00, 0.00}, {1.00, 1.00} } })

hl.config({ animations = { enabled = true } })


hl.animation({ leaf = "windows",     enabled = true, speed = 4, bezier = "windowBounce",      style = "slidevert" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4, bezier = "windowBounce",      style = "slidevert" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "emphasizedAccel",   style = "slidevert" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "standard",          style = "slide" })


hl.animation({ leaf = "layersIn",    enabled = true, speed = 4, bezier = "layerBounce",       style = "slidevert" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3, bezier = "emphasizedAccel",   style = "slidevert" })
hl.animation({ leaf = "layers",      enabled = true, speed = 4, bezier = "emphasized",        style = "slidevert" })

hl.animation({ leaf = "fadeIn",      enabled = true, speed = 4, bezier = "standard" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 3, bezier = "smoothOut" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 4, bezier = "standard" })
hl.animation({ leaf = "fadeShadow",  enabled = true, speed = 4, bezier = "standard" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 3, bezier = "smoothOut" })
hl.animation({ leaf = "fadeLayers",  enabled = true, speed = 4, bezier = "standard" })

hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "workspaceBounce",   style = "slidevert" })


hl.animation({ leaf = "border",      enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 20, bezier = "linear", style = "loop" })

hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
