hl.curve("standard",        { type = "bezier", points = { { 0.20, 0.00 }, { 0.20, 1.00 } } })
hl.curve("emphasized",      { type = "bezier", points = { { 0.12, 0.80 }, { 0.20, 1.00 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.30, 0.00 }, { 0.68, 0.10 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.95 }, { 0.15, 1.00 } } })
hl.curve("subtleBounce",    { type = "bezier", points = { { 0.16, 0.88 }, { 0.26, 1.02 } } })
hl.curve("snappy",          { type = "bezier", points = { { 0.08, 0.94 }, { 0.14, 1.00 } } })
hl.curve("linear",          { type = "bezier", points = { { 0.00, 0.00 }, { 1.00, 1.00 } } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "subtleBounce",    style = "slidevert" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3, bezier = "subtleBounce",    style = "slidevert" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, bezier = "emphasizedAccel", style = "slidevert" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "emphasizedDecel", style = "slide" })

hl.animation({ leaf = "layersIn",  enabled = true, speed = 3, bezier = "emphasized",      style = "slidevert" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "emphasizedAccel", style = "slidevert" })
hl.animation({ leaf = "layers",    enabled = true, speed = 3, bezier = "emphasized",      style = "slidevert" })

hl.animation({ leaf = "fadeIn",     enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 2, bezier = "emphasizedAccel" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2, bezier = "snappy" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 2, bezier = "snappy" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 3, bezier = "standard" })

hl.animation({ leaf = "workspaces",       enabled = true, speed = 3, bezier = "emphasizedDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "emphasizedDecel", style = "slidevert" })

hl.animation({ leaf = "border",      enabled = true, speed = 2,  bezier = "standard" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 15, bezier = "linear",     style = "loop" })

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 3, bezier = "emphasizedDecel" })
