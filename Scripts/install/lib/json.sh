pkg_list() {
    local key="${1}"
    jq -r ".${key}[]" "${PACKAGES_JSON}"
}

pkg_value() {
    local key="${1}"
    jq -r ".${key}" "${PACKAGES_JSON}"
}
