#!/bin/bash

# Define Catppuccin themes with a compact format
choices=$(cat <<EOF
──────────────────────────────────────────────────
Latte        ➜ Light, creamy theme      | ~/.local/share/catppuccin/latte.css
Frappé       ➜ Cool, soft theme         | frappe.css
Macchiato    ➜ Rich, dark theme         | macchiato.css
Mocha        ➜ Deep, warm theme         | mocha.css
──────────────────────────────────────────────────
EOF
)

# Display the menu with rofi and capture the selected option
selected=$(echo "$choices" | column -t -s '|' | rofi -dmenu -i -p "Catppuccin Theme" -theme "$HOME/.config/rofi/shortcut/style.rasi" -width 50 -lines 6)

# Check if a selection was made
if [ -z "$selected" ]; then
    exit 0
fi

# Skip divider lines
if [[ "$selected" =~ ^─ ]]; then
    exit 0
fi

# Extract the CSS file from the selected line (last column after the |)
css_file=$(echo "$selected" | awk -F '|' '{print $2}' | xargs)

# Check if CSS file is valid
if [ -z "$css_file" ]; then
    notify-send "Error" "No valid CSS file found for the selected theme."
    exit 1
fi

# Define paths
catppuccin_dir="$HOME/.local/share/catppuccin"
waybar_css="$HOME/.config/waybar/style.css"

# Check if the CSS file exists
if [ ! -f "$catppuccin_dir/$css_file" ]; then
    notify-send "Error" "CSS file $catppuccin_dir/$css_file not found."
    exit 1
fi

# Update Waybar's style.css to import the selected Catppuccin theme
cat > "$waybar_css" <<EOF
/* Waybar configuration with Catppuccin theme */
@import "$catppuccin_dir/$css_file";
EOF

# Restart Waybar to apply the new theme
pkill waybar
waybar & disown

# Notify user of successful theme application
notify-send "Waybar Theme" "Applied Catppuccin $css_file theme."
