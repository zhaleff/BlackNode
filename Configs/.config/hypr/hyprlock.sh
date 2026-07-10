#!/usr/bin/env bash

MONITOR_JSON=$(hyprctl monitors -j)
WIDTH=$(echo "$MONITOR_JSON" | jq '.[0].width')
HEIGHT=$(echo "$MONITOR_JSON" | jq '.[0].height')

PHOTO_SIZE=$((HEIGHT * 130 / 1080))

TIME_FONT=$((HEIGHT * 120 / 1080))
DATE_FONT=$((HEIGHT * 25 / 1080))
USER_FONT=$((HEIGHT * 18 / 1080))
SONG_FONT=$((HEIGHT * 18 / 1080))

BOX_W=$((WIDTH * 300 / 1920))
BOX_H=$((HEIGHT * 60 / 1080))

PHOTO_Y=$((HEIGHT * 40 / 1080))

DATE_Y=$((HEIGHT * 350 / 1080))
TIME_Y=$((HEIGHT * 250 / 1080))

USER_Y=$((HEIGHT * -130 / 1080))
INPUT_Y=$((HEIGHT * -210 / 1080))

SONG_Y=$((HEIGHT * 50 / 1080))

cat > ~/.config/hypr/hyprlock-generated.conf << EOF
# BACKGROUND
background {
    monitor =
    path = ~/.config/hypr/hyprlock.png
    blur_passes = 3
    contrast = 0.8916
    brightness = 0.8172
    vibrancy = 0.1696
    vibrancy_darkness = 0.0
}

# GENERAL
general {
    no_fade_in = false
    grace = 0
    disable_loading_bar = false
}

# PROFILE PHOTO
image {
    monitor =
    path = ~/.config/hypr/vivek.png

    border_size = 2
    border_color = rgba(255,255,255,0)

    size = $PHOTO_SIZE

    rounding = -1
    rotate = 0

    reload_time = -1

    position = 0, $PHOTO_Y
    halign = center
    valign = center
}

# DATE
label {
    monitor =
    text = cmd[update:1000] echo -e "\$(date +"%A, %B %d")"

    color = rgba(216,222,233,0.70)

    font_size = $DATE_FONT
    font_family = SF Pro Display Bold

    position = 0, $DATE_Y
    halign = center
    valign = center
}

# TIME
label {
    monitor =
    text = cmd[update:1000] echo "<span>\$(date +"%I:%M")</span>"

    color = rgba(216,222,233,0.70)

    font_size = $TIME_FONT
    font_family = SF Pro Display Bold

    position = 0, $TIME_Y
    halign = center
    valign = center
}

# USER BOX
shape {
    monitor =

    size = $BOX_W, $BOX_H

    color = rgba(255,255,255,0.10)

    rounding = -1
    border_size = 0
    border_color = rgba(253,198,135,0)

    rotate = 0
    xray = false

    position = 0, $USER_Y
    halign = center
    valign = center
}

# USER
label {
    monitor =

    text = \$USER

    color = rgba(216,222,233,0.80)

    outline_thickness = 2

    font_size = $USER_FONT
    font_family = SF Pro Display Bold

    position = 0, $USER_Y
    halign = center
    valign = center
}

# INPUT FIELD
input-field {
    monitor =

    size = $BOX_W, $BOX_H

    outline_thickness = 2

    dots_size = 0.2
    dots_spacing = 0.2
    dots_center = true

    outer_color = rgba(0,0,0,0)
    inner_color = rgba(255,255,255,0.10)

    font_color = rgb(200,200,200)

    fade_on_empty = false

    font_family = SF Pro Display Bold

    placeholder_text = <i><span foreground="##ffffff99">Enter Pass</span></i>

    hide_input = false

    position = 0, $INPUT_Y
    halign = center
    valign = center
}

# CURRENT SONG
label {
    monitor =

    text = cmd[update:1000] echo "\$(~/.config/hypr/Scripts/songdetail.sh)"

    color = rgba(255,255,255,0.60)

    font_size = $SONG_FONT
    font_family = JetBrains Mono Nerd Font, SF Pro Display Bold

    position = 0, $SONG_Y
    halign = center
    valign = bottom
}
EOF

exec hyprlock -c ~/.config/hypr/hyprlock-generated.conf
