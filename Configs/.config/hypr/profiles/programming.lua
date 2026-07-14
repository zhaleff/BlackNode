-- Programming profile
-- Wider master, persistent scratchpads, larger UI scale.

hl.config({
    master = {
        allow_small_split = true,
        mfact = 0.60,
    },
    windowrulev2 = {
        "workspace special:term,title:.*(kitty|alacritty).*",
        "workspace special:notes,title:.*(nvim|obsidian).*",
    },
    windowrule = {
        "opacity 1.0 override 1.0 override,.*",
    },
})

hl.env("WINIT_X11_SCALE_FACTOR", "1.2")
hl.env("GDK_DPI_SCALE", "1")
