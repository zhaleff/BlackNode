hint_for() {
    local cmd="${1}"
    case "${cmd}" in
        *makepkg*)
            echo -e "  ${ORANGE}::${NC}  Often fails if missing 'base-devel' or running as root."
            echo -e "  ${ORANGE}::${NC}  Fix: sudo pacman -S --needed base-devel"
            ;;
        *pacman*)
            echo -e "  ${ORANGE}::${NC}  Could be a mirror issue. Try:"
            echo -e "  ${ORANGE}::${NC}  ${DIM}sudo pacman -Syy${NC}"
            ;;
        *chsh*)
            echo -e "  ${ORANGE}::${NC}  chsh requires the shell to be in /etc/shells."
            echo -e "  ${ORANGE}::${NC}  Fix: echo \$(which zsh) | sudo tee -a /etc/shells"
            ;;
        *git\ clone*)
            echo -e "  ${ORANGE}::${NC}  Check your internet or github access."
            echo -e "  ${ORANGE}::${NC}  Try: ${DIM}git clone --depth 1${NC}"
            ;;
        *systemctl*)
            echo -e "  ${ORANGE}::${NC}  You may need to log out and back in."
            ;;
        *grub-mkconfig*)
            echo -e "  ${ORANGE}::${NC}  If grub-mkconfig fails, update manually:"
            echo -e "  ${ORANGE}::${NC}  ${DIM}sudo grub-mkconfig -o /boot/grub/grub.cfg${NC}"
            ;;
        *nvidia*)
            echo -e "  ${ORANGE}::${NC}  NVIDIA issues? Common fixes:"
            echo -e "  ${ORANGE}::${NC}  1. Rebuild initramfs: ${DIM}sudo mkinitcpio -P${NC}"
            echo -e "  ${ORANGE}::${NC}  2. Check nvidia_drm.modeset=1 kernel param"
            ;;
        *sddm*)
            echo -e "  ${ORANGE}::${NC}  Fix SDDM: ${DIM}sudo systemctl enable --now sddm${NC}"
            ;;
    esac
    echo -e "  ${ORANGE}::${NC}  Need more help?  ->  https://github.com/zhaleff/BlackNode/issues"
}
