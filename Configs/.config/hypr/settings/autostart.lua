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
  hl.exec_cmd("clipse -listen")
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
  hl.exec_cmd("sleep 0.5 && ~/.local/bin/media.sh")
  hl.exec_cmd("sleep 1 && ~/.local/bin/battery.sh")
  hl.exec_cmd("sleep 0.5 && ~/.local/bin/wifi.sh")
  hl.exec_cmd("sleep 1 && ~/.local/bin/weather.sh")
  hl.exec_cmd("sleep 0.5 && ~/.local/bin/device.sh")
   hl.exec_cmd("sleep 1 && ~/.local/bin/package.sh")
   hl.exec_cmd("sleep 2 && ~/.local/bin/blacknode-continuity.sh --restore")
   hl.exec_cmd("sleep 3 && ~/.local/bin/blacknode-greeter.sh")
   hl.exec_cmd("sleep 8 && ~/.local/bin/blacknode-whatsnew.sh --ping")
   hl.exec_cmd("sleep 2 && ~/.local/bin/blacknode-learn.py session")
   hl.exec_cmd("sleep 5 && ~/.local/bin/blacknode-learn.py sample-loop")
   hl.exec_cmd("sleep 30 && ~/.local/bin/blacknode-adapt")
end)
