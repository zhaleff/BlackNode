--                                                                               
--                       d8P                     d8P                        d8P  
--                    d888888P                d888888P                   d888888P
--  d888b8b  ?88   d8P  ?88'   d8888b  .d888b,  ?88'   d888b8b    88bd88b  ?88'  
-- d8P' ?88  d88   88   88P   d8P' ?88 ?8b,     88P   d8P' ?88    88P'  `  88P   
-- 88b  ,88b ?8(  d88   88b   88b  d88   `?8b   88b   88b  ,88b  d88       88b   
-- `?88P'`88b`?88P'?8b  `?8b  `?8888P'`?888P'   `?8b  `?88P'`88bd88'       `?8b  


hl.on("hyprland.start", function () 
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hypridle")  
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("dunst")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)
