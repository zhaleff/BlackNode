detect_gpu() {
    GPU_VENDOR=""
    GPU_NAME=""

    if command -v lspci &>/dev/null; then
        local gpu_line
        gpu_line=$(lspci -nn 2>/dev/null | grep -iE "VGA|3D|Display" | head -1)
        GPU_NAME=$(echo "${gpu_line}" | sed 's/.*: //; s/ \[.*//')

        if echo "${gpu_line}" | grep -qi "NVIDIA"; then
            GPU_VENDOR="nvidia"
        elif echo "${gpu_line}" | grep -qiE "AMD|Radeon|ATI"; then
            GPU_VENDOR="amd"
        elif echo "${gpu_line}" | grep -qi "Intel"; then
            GPU_VENDOR="intel"
        elif [[ -f /sys/class/drm/card0/device/vendor ]]; then
            local ven
            ven=$(cat /sys/class/drm/card0/device/vendor)
            case "${ven}" in
                0x10de) GPU_VENDOR="nvidia" ;;
                0x1002) GPU_VENDOR="amd" ;;
                0x8086) GPU_VENDOR="intel" ;;
            esac
        fi
    fi

    [[ -z "${GPU_VENDOR}" ]] && GPU_VENDOR="other"
    [[ -z "${GPU_NAME}" ]] && GPU_NAME="${GPU_VENDOR}"
}

detect_resolution() {
    MONITOR_RES=""
    MONITOR_NAME=""

    if command -v xrandr &>/dev/null && [[ -n "${DISPLAY:-}" ]]; then
        MONITOR_RES=$(xrandr 2>/dev/null | grep '*' | awk '{print $1}' | head -1)
        MONITOR_NAME=$(xrandr 2>/dev/null | grep '*' | awk '{print $2}' | head -1)
    elif command -v hyprctl &>/dev/null; then
        MONITOR_RES=$(hyprctl monitors 2>/dev/null | grep -m1 "resolution" | awk '{print $2}')
    elif [[ -d /sys/class/drm ]]; then
        local mode_file
        mode_file=$(ls /sys/class/drm/*/modes 2>/dev/null | head -1)
        [[ -n "${mode_file}" ]] && MONITOR_RES=$(head -1 "${mode_file}" 2>/dev/null)
    fi

    if [[ -z "${MONITOR_RES}" ]]; then
        local edid
        edid=$(find /sys/class/drm -name "edid" 2>/dev/null | head -1)
        if [[ -n "${edid}" ]]; then
            MONITOR_RES=$(hexdump -s 54 -n 4 -e '2/2 "%d"' "${edid}" 2>/dev/null | awk '{print $1"x"$2}')
        fi
    fi

    [[ -z "${MONITOR_RES}" ]] && MONITOR_RES="unknown"
    [[ -z "${MONITOR_NAME}" ]] && MONITOR_NAME=""
}

detect_language() {
    SYS_LANG="${LANG:-${LC_ALL:-unknown}}"
    SYS_LOCALE="$(locale 2>/dev/null | grep LANG= | cut -d= -f2 | tr -d '"')"
    [[ -z "${SYS_LOCALE}" ]] && SYS_LOCALE="${SYS_LANG}"
}

detect_desktop_env() {
    if [[ -z "${XDG_CURRENT_DESKTOP:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]] && [[ -z "${DISPLAY:-}" ]]; then
        warn "No desktop detected :: you might be in a TTY."
        info "You can install from here, then reboot into Hyprland."
        if ! confirm "Continue with installation?" "N"; then
            warn "Cancelled. Run from a desktop environment."
            exit 0
        fi
    fi
}
