hl.config({
    misc = {
        disable_autoreload = true,
        mouse_move_enables_dpms = false,
        key_press_enables_dpms = false,
    },
    general = {
        border_size = 0,
        no_border_on_floating = true,
    },
})

hl.window_rule("fullscreen,.*")
