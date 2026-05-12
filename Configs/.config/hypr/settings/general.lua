--                                                       d8b 
--                                                       88P 
--                                                      d88  
--  d888b8b   d8888b  88bd88b  d8888b  88bd88b d888b8b  888  
-- d8P' ?88  d8b_,dP  88P' ?8bd8b_,dP  88P'  `d8P' ?88  ?88  
-- 88b  ,88b 88b     d88   88P88b     d88     88b  ,88b  88b 
-- `?88P'`88b`?888P'd88'   88b`?888P'd88'     `?88P'`88b  88b
--        )88                                                
--       ,88P                                                
--   `?8888P                                                 


require("themes/hyprland")

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 7,
    border_size = 2,

    col = {
      active_border   = { colors = {"rgba(" .. color1 .. "ee)", "rgba(" .. color2 .. "ee)"}, angle = 45 },
      inactive_border = "rgba(" .. color0 .. "aa)",
    },
    layout = "dwindle",
    allow_tearing = false,
    resize_on_border = false,
  },
})
