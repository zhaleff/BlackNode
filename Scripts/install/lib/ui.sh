BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
TEAL='\033[0;36m'
BG_PURPLE='\033[45m'
ORANGE='\033[38;5;208m'

header() {
    echo ""
    echo -e "  ${BG_PURPLE}${BOLD}  ${*}  ${NC}"
    echo ""
}

step() {
    STEP=$((STEP + 1))
    echo ""
    echo -e "  ${PURPLE}${BOLD}:: ${STEP}/${TOTAL_STEPS}${NC}  ${BOLD}${*}${NC}"
    echo -e "  ${DIM}${PURPLE}----------------------------------------${NC}"
    echo ""
}

info()  { echo -e "  ${BLUE}::${NC}  ${*}"; }
ok()    { echo -e "  ${GREEN}::${NC}  ${*}"; }
warn()  { echo -e "  ${YELLOW}::${NC}  ${*}"; }
err()   { echo -e "  ${RED}::${NC}  ${*}"; }
dim()   { echo -e "  ${DIM}${*}${NC}"; }
hr()    { echo -e "  ${DIM}----------------------------------------${NC}"; }
tip()   { echo -e "  ${ORANGE}::${NC}  ${BOLD}TIP:${NC} ${*}"; }

confirm() {
    local msg="${1}" default="${2:-Y}"
    local yn="Y/n"
    [[ "${default}" == "N" ]] && yn="y/N"
    echo -ne "  ${TEAL}::${NC} ${BOLD}${msg}${NC} ${DIM}[${yn}]${NC} "
    read -r ans
    [[ -z "${ans}" ]] && ans="${default}"
    [[ "${ans}" =~ ^[Yy] ]]
}

choose() {
    local msg="${1}" default="${2:-}" opts="${3:-}"
    local opt_hint=""
    [[ -n "${opts}" ]] && opt_hint=" ${DIM}(${opts})${NC}"
    echo -ne "  ${TEAL}::${NC} ${BOLD}${msg}${NC}${opt_hint} "
    read -r ans
    [[ -z "${ans}" ]] && ans="${default}"
    echo "${ans}"
}

press_enter() {
    echo -ne "  ${DIM}Press ENTER to continue${NC} "
    read -r _
}
