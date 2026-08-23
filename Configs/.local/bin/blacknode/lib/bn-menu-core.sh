#!/usr/bin/env bash
# ============================================================================
# BlackNode Menu - Domain Core (hexagonal architecture)
# ============================================================================
#
# This is the ONLY place that knows what a menu *is*. It never talks to
# rofi, dunst or any tool directly: it defines PORTS and lets ADAPTERS
# implement them.
#
#   Ports (contracts every adapter must fulfill):
#     bn_ui_select <prompt>   options arrive on stdin (newline separated);
#                             echoes the chosen line; empty string on cancel.
#     bn_notify <title> <msg> user feedback channel (dunst under rofi).
#
#   Adapters live in "$BN_ROOT/adapters/<name>.sh" and are selected with
#   BN_UI=rofi|cli (default: rofi). Adding a UI = adding one adapter file.
#
#   Modules are pure data: one manifest per module in "$BN_ROOT/modules.d":
#
#     id=window            unique slug (required)
#     label=Window         display name (required)
#     icon=󰖰              nerd-font glyph
#     group=Workspace      section header in the menu
#     weight=10            order inside the group (lower = first)
#     desc=Tiling rules    shown by text adapters / future tooltips
#     action=$BN_SCRIPTS/window/menu.sh   executed via `bash -c`
#     require=nmcli clipse binaries that must exist (module hidden otherwise)
#
#   Adding functionality to the menu NEVER touches this file:
#   drop a .conf in modules.d (and optionally a script under scripts/).
#
#   Environment switches:
#     BN_DRYRUN=1   print resolved actions instead of executing them
#     BN_LIST=1     print the discovered module table and exit
#     BN_UI=...     presentation adapter
# ============================================================================

BN_GROUP_ORDER=(Workspace System Appearance Focus Devices BlackNode)

declare -a BN_IDS=() BN_LABELS=() BN_ICONS=() BN_DESCS=()
declare -a BN_GROUPS=() BN_ACTIONS=() BN_WEIGHTS=()
declare -A BN_LINE_TO_ID=()

# ---------------------------------------------------------------- ports ----

bn_load_adapter() {
    local ui="${BN_UI:-rofi}"
    local file="$BN_ROOT/adapters/$ui.sh"
    [[ -f "$file" ]] || { echo "bn-menu: unknown adapter '$ui'" >&2; return 1; }
    # shellcheck disable=SC1090
    source "$file"
}

bn_notify() {
    command -v bn_notify_impl >/dev/null || bn_load_adapter >&2
    bn_notify_impl "$@"
}

bn_run() {
    local id="$1" action="$2"
    if [[ "${BN_DRYRUN:-0}" == "1" ]]; then
        echo "[dry-run] $id -> $action"
        return 0
    fi
    export BN_MENU_ID="$id" BN_ROOT BN_SCRIPTS BN_MODULES_DIR
    bash -c "$action"
}

# ----------------------------------------------------------- discovery ----

bn_parse_manifest() {
    local file="$1"
    local _id="" _label="" _icon="" _group="" _desc="" _action="" _require="" _weight="50"
    local key val line
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"; line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        [[ "$line" != *=* ]] && continue
        key="${line%%=*}"; val="${line#*=}"
        case "$key" in
            id)      _id="$val" ;;
            label)   _label="$val" ;;
            icon)    _icon="$val" ;;
            group)   _group="$val" ;;
            desc)    _desc="$val" ;;
            action)  _action="$val" ;;
            require) _require="$val" ;;
            weight)  _weight="$val" ;;
            *) echo "bn-menu: unknown key '$key' in ${file##*/}" >&2 ;;
        esac
    done < "$file"

    if [[ -z "$_id" || -z "$_label" || -z "$_action" ]]; then
        echo "bn-menu: skipping ${file##*/} (needs id, label and action)" >&2
        return 1
    fi
    local bin
    for bin in $_require; do
        if ! command -v "$bin" >/dev/null 2>&1; then
            echo "bn-menu: hidden '$_id' (missing dependency: $bin)" >&2
            return 1
        fi
    done
    printf '%s\n' "$_id" "$_label" "$_icon" "$_group" "$_desc" "$_action" "$_weight"
}

bn_discover_modules() {
    BN_MODULES_DIR="${BN_MODULES_DIR:-$BN_ROOT/modules.d}"
    local -A seen_ids=()
    local file found=0
    while IFS= read -r file; do
        local parsed
        parsed="$(bn_parse_manifest "$file")" || continue
        local id label icon group desc action weight
        { read -r id; read -r label; read -r icon; read -r group;
          read -r desc; read -r action; read -r weight; } <<<"$parsed"
        if [[ -n "${seen_ids[$id]:-}" ]]; then
            echo "bn-menu: duplicate module id '$id' in ${file##*/} (ignored)" >&2
            continue
        fi
        BN_IDS+=("$id"); BN_LABELS+=("$label"); BN_ICONS+=("$icon")
        BN_DESCS+=("$desc"); BN_GROUPS+=("$group"); BN_ACTIONS+=("$action")
        BN_WEIGHTS+=("${weight:-50}")
        seen_ids[$id]=1
        found=$((found+1))
    done < <(find "$BN_MODULES_DIR" -maxdepth 1 -name '*.conf' | sort)
    (( found > 0 )) || { echo "bn-menu: no modules found in $BN_MODULES_DIR" >&2; return 1; }
}

bn_group_rank() {
    local g="$1" i
    for i in "${!BN_GROUP_ORDER[@]}"; do
        [[ "${BN_GROUP_ORDER[i]}" == "$g" ]] && { echo "$i"; return; }
    done
    echo "${#BN_GROUP_ORDER[@]}"
}

bn_sort_modules() {
    local n=${#BN_IDS[@]}
    (( n > 0 )) || return 0
    local -a order=()
    local i
    mapfile -t order < <(
        for ((i=0; i<n; i++)); do
            printf '%03d\t%05d\t%s\t%d\n' \
                "$(bn_group_rank "${BN_GROUPS[i]}")" \
                "${BN_WEIGHTS[i]}" \
                "${BN_LABELS[i],,}" \
                "$i"
        done | LC_ALL=C sort -t$'\t' -k1,1 -k2,2 -k3,3 | cut -f4
    )
    local -a s_ids=() s_labels=() s_icons=() s_descs=() s_groups=() s_actions=() s_weights=()
    for i in "${order[@]}"; do
        s_ids+=("${BN_IDS[i]}"); s_labels+=("${BN_LABELS[i]}"); s_icons+=("${BN_ICONS[i]}")
        s_descs+=("${BN_DESCS[i]}"); s_groups+=("${BN_GROUPS[i]}"); s_actions+=("${BN_ACTIONS[i]}")
        s_weights+=("${BN_WEIGHTS[i]}")
    done
    BN_IDS=("${s_ids[@]}"); BN_LABELS=("${s_labels[@]}"); BN_ICONS=("${s_icons[@]}")
    BN_DESCS=("${s_descs[@]}"); BN_GROUPS=("${s_groups[@]}"); BN_ACTIONS=("${s_actions[@]}")
    BN_WEIGHTS=("${s_weights[@]}")
}

# ------------------------------------------------------------- render -----
# NOTE: builds state in the CURRENT shell on purpose. Never call it inside
# $( ) or a pipeline — associative state must survive into dispatch.

bn_build_lines() {
    declare -gA BN_LINE_TO_ID=()
    declare -ga BN_LINES=()
    local last_group="" i line
    for i in "${!BN_IDS[@]}"; do
        if [[ "${BN_GROUPS[i]}" != "$last_group" ]]; then
            last_group="${BN_GROUPS[i]}"
            BN_LINE_TO_ID["── $last_group"]=""
            BN_LINES+=("── $last_group")
        fi
        line="${BN_ICONS[i]}  ${BN_LABELS[i]}"
        BN_LINE_TO_ID["$line"]="${BN_IDS[i]}"
        BN_LINES+=("$line")
    done
}

bn_list_modules() {
    local i
    printf '%-18s %-14s %-11s %7s  %s\n' ID GROUP LABEL WEIGHT ACTION
    for i in "${!BN_IDS[@]}"; do
        printf '%-18s %-14s %-11s %7s  %s\n' \
            "${BN_IDS[i]}" "${BN_GROUPS[i]}" "${BN_LABELS[i]}" "${BN_WEIGHTS[i]}" "${BN_ACTIONS[i]}"
    done
}

# --------------------------------------------------------------- main -----

bn_menu_main() {
    bn_load_adapter || return 1
    bn_discover_modules || return 1
    bn_sort_modules

    if [[ "${BN_LIST:-0}" == "1" ]]; then bn_list_modules; return 0; fi

    local choice id
    bn_build_lines
    choice="$(printf '%s\n' "${BN_LINES[@]}" | bn_ui_select "")"
    [[ -z "$choice" ]] && return 0

    id="${BN_LINE_TO_ID[$choice]:-}"
    [[ -z "$id" ]] && return 0   # section header or unknown pick: silent exit

    local i action=""
    for i in "${!BN_IDS[@]}"; do
        [[ "${BN_IDS[i]}" == "$id" ]] && { action="${BN_ACTIONS[i]}"; break; }
    done
    [[ -n "$action" ]] && bn_run "$id" "$action"
}
