hl.config({
    animations = {
        "workspaces,0",
        "fade,0",
        "border,0",
        "windows,0",
    },
    misc = {
        disable_autoreload = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        always_follow_on_dpi = true,
    },
})

hl.window_rule("fullscreen,.*")
hl.window_rule("noanim,.*")
