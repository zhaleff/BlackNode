MAX_SHOWN = 15
HEADER_ICON = "\U000F03D6"
DEFAULT_ICON = "\U000F03D7"

ICON_MAP = (
    (("linux", "linux-lts", "linux-zen", "linux-hardened", "linux-headers"), "\U000F0833"),
    (("nvidia", "xf86-video-"), "\U000F08AE"),
    (("mesa",), "\U000F08AE"),
    (("systemd",), "\U000F0493"),
    (("pacman", "archlinux-keyring"), "\U000F0BAF"),
    (("glibc", "gcc-libs", "binutils"), "\U000F08E9"),
    (("docker", "podman"), "\U000F0868"),
    (("code", "visual-studio-code-bin"), "\U000F0A1E"),
    (("python",), "\U000F0320"),
    (("nodejs", "npm"), "\U000F0399"),
    (("rust", "cargo"), "\U000F1617"),
    (("firefox",), "\U000F0239"),
    (("chromium", "google-chrome", "brave"), "\U000F02AF"),
    (("gtk", "qt5", "qt6"), "\U000F018D"),
)

TIER_MAP = (
    (("linux", "linux-lts", "linux-zen", "linux-hardened", "linux-headers"), 0),
    (("nvidia", "xf86-video-", "mesa"), 1),
    (("systemd", "pacman", "archlinux-keyring", "glibc", "gcc-libs", "binutils"), 2),
    (("docker", "podman", "code", "visual-studio-code-bin", "neovim", "vim", "nvim",
      "python", "nodejs", "npm", "rust", "cargo"), 3),
)


def icon_for(pkg):
    for prefixes, icon in ICON_MAP:
        if any(pkg.startswith(p) for p in prefixes):
            return icon
    return DEFAULT_ICON


def tier_for(pkg):
    for prefixes, tier in TIER_MAP:
        if any(pkg.startswith(p) for p in prefixes):
            return tier
    return 4


def order(updates):
    tiers = {t: [] for t in range(5)}
    for line in updates:
        pkg = line.split(" ", 1)[0]
        tiers[tier_for(pkg)].append(line)
    ordered = []
    for t in range(5):
        ordered.extend(tiers[t])
    return ordered