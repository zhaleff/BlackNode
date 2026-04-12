#!/usr/bin/env bash
# =============================================================================
# blacknode.sh - BlackNode Installation Orchestrator
# =============================================================================
# Strictly modular dispatcher / controller.
# This script ONLY orchestrates calls to independent, self-contained scripts.
# It does NOT install, configure, or duplicate any logic.
#
# Each feature lives in its own .sh file and is executed exactly as-is.
#
# Execution flow (mandatory):
#   1. welcome.sh
#   2. Optional: introduction.sh + information.sh
#   3. Clean interactive menu (British English)
#   4. User selects → only chosen scripts are called
#
# Easy to extend: just add entries to the component_* arrays below.
# =============================================================================

# =============================================================================
# COLOUR PALETTE (exactly as specified)
# =============================================================================
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
WHITE="\033[1;37m"
CYAN="\033[0;36m"
CYAN_B="\033[1;36m"
GRAY="\033[0;90m"
BLUE_B="\033[1;34m"

# =============================================================================
# HEADER & AESTHETIC OUTPUT
# =============================================================================
print_header() {
    # Minimalist hacker-style banner (clean, no childish flair)
    echo -e "${BLUE_B}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "${BLUE_B}┃${RESET}                  ${CYAN_B}B L A C K N O D E${RESET}                  ${BLUE_B}┃${RESET}"
    echo -e "${BLUE_B}┃${RESET}               Modular Installation Orchestrator               ${BLUE_B}┃${RESET}"
    echo -e "${BLUE_B}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    echo -e "${DIM}               aesthetic • minimal • strictly modular${RESET}"
    echo ""
}

print_separator() {
    echo -e "${GRAY}────────────────────────────────────────────────────────────${RESET}"
}

# =============================================================================
# COMPONENT REGISTRY
# Easy to expand: add name + script filename pair (keep order logical)
# =============================================================================
component_names=(
    "Hyprland (Wayland compositor)"
    "Waybar (status bar)"
    "Rofi (application launcher)"
    "Wlogout (logout menu)"
    "Hyprlock (screen locker)"
    "Hyprshot (screenshot utility)"
    "Wallpaper setup"
    "Wallust (colour scheme generator)"
    "Zsh shell & configuration"
    "Neovim text editor"
    "Yazi terminal file manager"
    "Fastfetch (system fetch)"
    "Cava audio visualiser"
    "Clipse clipboard manager"
    "Aww (widgets / notifications)"
    "Flatpak support"
    "Yay (AUR helper)"
    "Bin (custom utilities)"
    "Update system packages"
    "View changelog"
)

component_scripts=(
    "hyprland.sh"
    "waybar.sh"
    "rofi.sh"
    "wlogout.sh"
    "hyprlock.sh"
    "hyprshot.sh"
    "wallpaper.sh"
    "wallust.sh"
    "zsh.sh"
    "nvim.sh"
    "yazi.sh"
    "fastfetch.sh"
    "cava.sh"
    "clipse.sh"
    "aww.sh"
    "flatpak.sh"
    "yay.sh"
    "bin.sh"
    "update.sh"
    "changelog.sh"
)

# =============================================================================
# MAIN EXECUTION
# =============================================================================
main() {
    print_header

    # -------------------------------------------------------------------------
    # 1. Mandatory welcome sequence
    # -------------------------------------------------------------------------
    echo -e "${CYAN_B}► Initialising BlackNode environment...${RESET}"
    print_separator
    if [[ -f "./welcome.sh" ]]; then
        echo -e "${CYAN}Running welcome.sh${RESET}"
        bash "./welcome.sh"
    else
        echo -e "${GRAY}⚠  welcome.sh not found – skipping${RESET}"
    fi
    echo ""

    # -------------------------------------------------------------------------
    # 2. Optional introduction / information
    # -------------------------------------------------------------------------
    read -r -p "Would you like to view the introduction? (y/n): " intro_choice
    if [[ "$intro_choice" =~ ^[Yy]$ ]]; then
        if [[ -f "./introduction.sh" ]]; then
            echo -e "${CYAN}Running introduction.sh${RESET}"
            bash "./introduction.sh"
            echo ""
        fi
    fi

    read -r -p "Would you like to view additional information? (y/n): " info_choice
    if [[ "$info_choice" =~ ^[Yy]$ ]]; then
        if [[ -f "./information.sh" ]]; then
            echo -e "${CYAN}Running information.sh${RESET}"
            bash "./information.sh"
            echo ""
        fi
    fi

    # -------------------------------------------------------------------------
    # 3. Interactive component selection (loop until valid choice)
    # -------------------------------------------------------------------------
    while true; do
        print_header
        echo -e "${BLUE_B}Component Selection${RESET}"
        echo -e "${CYAN}Choose which modules to execute (each runs independently).${RESET}"
        echo ""

        # Display numbered list
        for i in "${!component_names[@]}"; do
            printf "${CYAN}%2d${RESET}) ${WHITE}%s${RESET} ${GRAY}(%s)${RESET}\n" \
                "$((i+1))" "${component_names[$i]}" "${component_scripts[$i]}"
        done

        echo ""
        echo -e "${DIM}Tip: enter numbers separated by spaces (e.g. 1 3 5 8)"
        echo -e "     or type ${CYAN}all${RESET} for complete setup"
        echo -e "     or type ${CYAN}h${RESET} for help${RESET}"
        echo ""

        read -r -p "Your selection: " raw_input
        raw_input=$(echo "$raw_input" | tr '[:upper:]' '[:lower:]')

        # Help request
        if [[ "$raw_input" == "h" || "$raw_input" == "help" ]]; then
            echo -e "${CYAN}Launching help system...${RESET}"
            if [[ -f "./help.sh" ]]; then
                bash "./help.sh"
            else
                echo -e "${GRAY}help.sh not found${RESET}"
            fi
            echo -e "${DIM}Returning to selection menu...${RESET}"
            echo ""
            continue
        fi

        # Process selection
        selected_scripts=()
        selected_indices=()

        if [[ "$raw_input" == "all" ]]; then
            # User explicitly chose complete setup
            for i in "${!component_scripts[@]}"; do
                selected_indices+=("$i")
            done
        else
            # Parse space-separated numbers
            for num in $raw_input; do
                if [[ "$num" =~ ^[0-9]+$ ]]; then
                    idx=$((num - 1))
                    if [[ $idx -ge 0 && $idx -lt ${#component_scripts[@]} ]]; then
                        selected_indices+=("$idx")
                    fi
                fi
            done
        fi

        # Remove duplicates and sort to preserve logical execution order
        if [[ ${#selected_indices[@]} -eq 0 ]]; then
            echo -e "${GRAY}No components selected. Please try again.${RESET}"
            continue
        fi

        # deduplicate + sort indices
        mapfile -t selected_indices < <(printf "%s\n" "${selected_indices[@]}" | sort -nu)

        for idx in "${selected_indices[@]}"; do
            selected_scripts+=("${component_scripts[$idx]}")
        done

        # Confirmation
        echo ""
        print_separator
        echo -e "${WHITE}You have selected the following modules:${RESET}"
        for script in "${selected_scripts[@]}"; do
            echo -e "   ${CYAN}▶${RESET} ${script}"
        done
        echo ""
        read -r -p "Proceed with execution? (y/n): " confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            break
        else
            echo -e "${GRAY}Selection cancelled. Returning to menu...${RESET}"
            echo ""
        fi
    done

    # -------------------------------------------------------------------------
    # 4. Execute only the chosen scripts (modular orchestration)
    # -------------------------------------------------------------------------
    echo ""
    print_separator
    echo -e "${CYAN_B}► Starting modular orchestration...${RESET}"
    echo -e "${DIM}Only selected scripts will run. No logic is duplicated here.${RESET}"
    echo ""

    for script in "${selected_scripts[@]}"; do
        if [[ -f "./${script}" ]]; then
            echo -e "${CYAN_B}Executing → ${BOLD}${script}${RESET}"
            print_separator
            # Call exactly as an independent script (no sourcing, no inline logic)
            bash "./${script}"
            echo ""
            echo -e "${GRAY}✓ ${script} completed${RESET}"
            echo ""
        else
            echo -e "${GRAY}⚠  ${script} not found – skipping${RESET}"
        fi
    done

    # -------------------------------------------------------------------------
    # 5. Final message
    # -------------------------------------------------------------------------
    print_separator
    echo -e "${CYAN_B}Orchestration complete.${RESET}"
    echo -e "${WHITE}BlackNode is now configured exactly as you requested.${RESET}"
    echo -e "${DIM}Thank you for using the modular installer.${RESET}"
    echo ""
}

# =============================================================================
# LAUNCH
# =============================================================================
main
