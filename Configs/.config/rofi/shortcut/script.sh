#!/bin/bash

# Source the programs.conf file to load variables like $terminal, $browser, etc.
source ~/.config/hypr/system/programs.conf

# Define the main modifier key
mainMod="SUPER"

# Define the choices for the rofi menu, organized by sections
choices=$(cat <<EOF
======= General =======
${mainMod} + D            ⟹ Open Terminal ($terminal)
${mainMod} + Q            ⟹ Kill Active Window
${mainMod} + P            ⟹ Pseudo
${mainMod} + J            ⟹ Toggle Split
${mainMod} + Shift + F    ⟹ Fullscreen
${mainMod} + F            ⟹ Toggle Floating
=======
======= Applications & Tools =======
Ctrl + Alt + Up           ⟹ Open Launcher ($launch)
${mainMod} + Shift + X    ⟹ Open Logout Menu ($logout)
${mainMod} + W            ⟹ Wallpaper Selector ($wallselect)
${mainMod} + C            ⟹ Open Clipboard (clipse)
${mainMod} + B            ⟹ Open Browser ($browser)
${mainMod} + Y            ⟹ Open Music Player ($music)
${mainMod} + R            ⟹ Open App Launcher ($launcher)
${mainMod} + Shift + C    ⟹ Open Clipboard Manager ($clipboard)
${mainMod} + H            ⟹ Take Screenshot ($screenshot)
${mainMod} + A            ⟹ Open WiFi Manager ($wifi)
${mainMod} + E            ⟹ Open File Manager ($fileManager)
${mainMod} + L            ⟹ Lock Screen ($lock)
${mainMod} + X            ⟹ Open Wayland Logout ($logout-w)
${mainMod} + Shift + A    ⟹ Open Audio Manager ($audio)
${mainMod} + Shift + I    ⟹ Toggle Animations ($animation)
=======
======= Navigation =======
${mainMod} + Left         ⟹ Move Focus Left
${mainMod} + Right        ⟹ Move Focus Right
${mainMod} + Up           ⟹ Move Focus Up
${mainMod} + Down         ⟹ Move Focus Down
=======
======= Workspaces =======
${mainMod} + 1            ⟹ Switch to Workspace 1
${mainMod} + 2            ⟹ Switch to Workspace 2
${mainMod} + 3            ⟹ Switch to Workspace 3
${mainMod} + 4            ⟹ Switch to Workspace 4
${mainMod} + 5            ⟹ Switch to Workspace 5
${mainMod} + 6            ⟹ Switch to Workspace 6
${mainMod} + 7            ⟹ Switch to Workspace 7
${mainMod} + 8            ⟹ Switch to Workspace 8
${mainMod} + 9            ⟹ Switch to Workspace 9
${mainMod} + 0            ⟹ Switch to Workspace 10
${mainMod} + Shift + 1    ⟹ Move Window to Workspace 1
${mainMod} + Shift + 2    ⟹ Move Window to Workspace 2
${mainMod} + Shift + 3    ⟹ Move Window to Workspace 3
${mainMod} + Shift + 4    ⟹ Move Window to Workspace 4
${mainMod} + Shift + 5    ⟹ Move Window to Workspace 5
${mainMod} + Shift + 6    ⟹ Move Window to Workspace 6
${mainMod} + Shift + 7    ⟹ Move Window to Workspace 7
${mainMod} + Shift + 8    ⟹ Move Window to Workspace 8
${mainMod} + Shift + 9    ⟹ Move Window to Workspace 9
${mainMod} + Shift + 0    ⟹ Move Window to Workspace 10
${mainMod} + S            ⟹ Toggle Special Workspace
${mainMod} + Shift + S    ⟹ Move to Special Workspace
=======
======= Scroll Workspaces =======
${mainMod} + Mouse Down   ⟹ Next Workspace
${mainMod} + Mouse Up     ⟹ Previous Workspace
=======
======= Multimedia Keys =======
XF86AudioRaiseVolume      ⟹ Volume Up
XF86AudioLowerVolume      ⟹ Volume Down
XF86AudioMute             ⟹ Mute Audio
XF86AudioMicMute          ⟹ Mute Microphone
XF86MonBrightnessUp       ⟹ Brightness Up
XF86MonBrightnessDown     ⟹ Brightness Down
=======
======= Media Player Controls =======
XF86AudioNext             ⟹ Next Track
XF86AudioPause            ⟹ Play/Pause
XF86AudioPlay             ⟹ Play/Pause
XF86AudioPrev             ⟹ Previous Track
=======
EOF
)

# Display the rofi menu and capture the selected option
selected=$(echo "$choices" | rofi -dmenu -i -p "Shortcuts" -theme "$HOME/.config/rofi/shortcut/style.rasi")

# Execute the corresponding command based on the selection
case "$selected" in
    "${mainMod} + D            ⟹ Open Terminal ($terminal)")
        $terminal ;;
    "${mainMod} + Q            ⟹ Kill Active Window")
        hyprctl dispatch killactive ;;
    "${mainMod} + P            ⟹ Pseudo")
        hyprctl dispatch pseudo ;;
    "${mainMod} + J            ⟹ Toggle Split")
        hyprctl dispatch togglesplit ;;
    "${mainMod} + Shift + F    ⟹ Fullscreen")
        hyprctl dispatch fullscreen ;;
    "${mainMod} + F            ⟹ Toggle Floating")
        hyprctl dispatch togglefloating ;;
    "Ctrl + Alt + Up           ⟹ Open Launcher ($launch)")
        $launch ;;
    "${mainMod} + Shift + X    ⟹ Open Logout Menu ($logout)")
        $logout ;;
    "${mainMod} + W            ⟹ Wallpaper Selector ($wallselect)")
        $wallselect ;;
    "${mainMod} + C            ⟹ Open Clipboard (clipse)")
        kitty --class clipse -e clipse ;;
    "${mainMod} + B            ⟹ Open Browser ($browser)")
        $browser ;;
    "${mainMod} + Y            ⟹ Open Music Player ($music)")
        $music ;;
    "${mainMod} + R            ⟹ Open App Launcher ($launcher)")
        $launcher ;;
    "${mainMod} + Shift + C    ⟹ Open Clipboard Manager ($clipboard)")
        $clipboard ;;
    "${mainMod} + H            ⟹ Take Screenshot ($screenshot)")
        $screenshot ;;
    "${mainMod} + A            ⟹ Open WiFi Manager ($wifi)")
        $wifi ;;
    "${mainMod} + E            ⟹ Open File Manager ($fileManager)")
        $fileManager ;;
    "${mainMod} + L            ⟹ Lock Screen ($lock)")
        $lock ;;
    "${mainMod} + X            ⟹ Open Wayland Logout ($logout-w)")
        $logout-w ;;
    "${mainMod} + Shift + A    ⟹ Open Audio Manager ($audio)")
        $audio ;;
    "${mainMod} + Shift + I    ⟹ Toggle Animations ($animation)")
        $animation ;;
    "${mainMod} + Left         ⟹ Move Focus Left")
        hyprctl dispatch movefocus l ;;
    "${mainMod} + Right        ⟹ Move Focus Right")
        hyprctl dispatch movefocus r ;;
    "${mainMod} + Up           ⟹ Move Focus Up")
        hyprctl dispatch movefocus u ;;
    "${mainMod} + Down         ⟹ Move Focus Down")
        hyprctl dispatch movefocus d ;;
    "${mainMod} + 1            ⟹ Switch to Workspace 1")
        hyprctl dispatch workspace 1 ;;
    "${mainMod} + 2            ⟹ Switch to Workspace 2")
        hyprctl dispatch workspace 2 ;;
    "${mainMod} + 3            ⟹ Switch to Workspace 3")
        hyprctl dispatch workspace 3 ;;
    "${mainMod} + 4            ⟹ Switch to Workspace 4")
        hyprctl dispatch workspace 4 ;;
    "${mainMod} + 5            ⟹ Switch to Workspace 5")
        hyprctl dispatch workspace 5 ;;
    "${mainMod} + 6            ⟹ Switch to Workspace 6")
        hyprctl dispatch workspace 6 ;;
    "${mainMod} + 7            ⟹ Switch to Workspace 7")
        hyprctl dispatch workspace 7 ;;
    "${mainMod} + 8            ⟹ Switch to Workspace 8")
        hyprctl dispatch workspace 8 ;;
    "${mainMod} + 9            ⟹ Switch to Workspace 9")
        hyprctl dispatch workspace 9 ;;
    "${mainMod} + 0            ⟹ Switch to Workspace 10")
        hyprctl dispatch workspace 10 ;;
    "${mainMod} + Shift + 1    ⟹ Move Window to Workspace 1")
        hyprctl dispatch movetoworkspace 1 ;;
    "${mainMod} + Shift + 2    ⟹ Move Window to Workspace 2")
        hyprctl dispatch movetoworkspace 2 ;;
    "${mainMod} + Shift + 3    ⟹ Move Window to Workspace 3")
        hyprctl dispatch movetoworkspace 3 ;;
    "${mainMod} + Shift + 4    ⟹ Move Window to Workspace 4")
        hyprctl dispatch movetoworkspace 4 ;;
    "${mainMod} + Shift + 5    ⟹ Move Window to Workspace 5")
        hyprctl dispatch movetoworkspace 5 ;;
    "${mainMod} + Shift + 6    ⟹ Move Window to Workspace 6")
        hyprctl dispatch movetoworkspace 6 ;;
    "${mainMod} + Shift + 7    ⟹ Move Window to Workspace 7")
        hyprctl dispatch movetoworkspace 7 ;;
    "${mainMod} + Shift + 8    ⟹ Move Window to Workspace 8")
        hyprctl dispatch movetoworkspace 8 ;;
    "${mainMod} + Shift + 9    ⟹ Move Window to Workspace 9")
        hyprctl dispatch movetoworkspace 9 ;;
    "${mainMod} + Shift + 0    ⟹ Move Window to Workspace 10")
        hyprctl dispatch movetoworkspace 10 ;;
    "${mainMod} + S            ⟹ Toggle Special Workspace")
        hyprctl dispatch togglespecialworkspace magic ;;
    "${mainMod} + Shift + S    ⟹ Move to Special Workspace")
        hyprctl dispatch movetoworkspace special:magic ;;
    "${mainMod} + Mouse Down   ⟹ Next Workspace")
        hyprctl dispatch workspace e+1 ;;
    "${mainMod} + Mouse Up     ⟹ Previous Workspace")
        hyprctl dispatch workspace e-1 ;;
    "XF86AudioRaiseVolume      ⟹ Volume Up")
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    "XF86AudioLowerVolume      ⟹ Volume Down")
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    "XF86AudioMute             ⟹ Mute Audio")
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    "XF86AudioMicMute          ⟹ Mute Microphone")
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
    "XF86MonBrightnessUp       ⟹ Brightness Up")
        brightnessctl s 10%+ ;;
    "XF86MonBrightnessDown     ⟹ Brightness Down")
        brightnessctl s 10%- ;;
    "XF86AudioNext             ⟹ Next Track")
        playerctl next ;;
    "XF86AudioPause            ⟹ Play/Pause")
        playerctl play-pause ;;
    "XF86AudioPlay             ⟹ Play/Pause")
        playerctl play-pause ;;
    "XF86AudioPrev             ⟹ Previous Track")
        playerctl previous ;;
    *)
        exit 0 ;; # Exit if no valid selection is made
esac
