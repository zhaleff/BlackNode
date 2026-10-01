
hl.curve("microBounce", { type = "bezier", points = { { 0.15, 0.85 }, { 0.20, 1.04 } } })

hl.curve("snappy",      { type = "bezier", points = { { 0.30, 0.00 }, { 0.00, 1.00 } } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",     enabled = true, speed = 1.2, bezier = "microBounce", style = "popin 97%" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 1.2, bezier = "microBounce", style = "popin 97%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 0.8, bezier = "snappy",      style = "popin 97%" }) 
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.2, bezier = "snappy",      style = "slide" })


hl.animation({ leaf = "layers",    enabled = true, speed = 1.2, bezier = "microBounce", style = "slide" })
hl.animation({ leaf = "layersIn",  enabled = true, speed = 1.2, bezier = "microBounce", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.8, bezier = "snappy",      style = "slide" })

hl.animation({ leaf = "fadeIn",     enabled = true, speed = 1.0, bezier = "snappy" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 0.6, bezier = "snappy" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.0, bezier = "snappy" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 1.2, bezier = "snappy" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 1.0, bezier = "snappy" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 1.2, bezier = "snappy" })

hl.animation({ leaf = "workspaces",       enabled = true, speed = 1.5, bezier = "microBounce", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1.5, bezier = "microBounce", style = "slidevert" })

hl.animation({ leaf = "border",      enabled = true, speed = 1.2, bezier = "snappy" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 15,  bezier = "linear", style = "loop" })
hl.animation({ leaf = "zoomFactor",  enabled = true, speed = 1.2, bezier = "microBounce" })
