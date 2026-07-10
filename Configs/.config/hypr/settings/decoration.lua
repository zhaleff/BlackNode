--       d8b                                                    d8,                  
--       88P                                             d8P   `8P                   
--      d88                                           d888888P                       
--  d888888   d8888b d8888b d8888b   88bd88b d888b8b    ?88'    88b d8888b   88bd88b 
-- d8P' ?88  d8b_,dPd8P' `Pd8P' ?88  88P'  `d8P' ?88    88P     88Pd8P' ?88  88P' ?8b
-- 88b  ,88b 88b    88b    88b  d88 d88     88b  ,88b   88b    d88 88b  d88 d88   88P
-- `?88P'`88b`?888P'`?888P'`?8888P'd88'     `?88P'`88b  `?8b  d88' `?8888P'd88'   88b

hl.config({
  decoration = {
    rounding = 10,
    dim_special = 0.3,
    rounding_power = 2,
    active_opacity = 1,
    inactive_opacity = 0.8,
    shadow = {
      enabled = false,
    },
    blur = {
      special = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
    },

  },
})
