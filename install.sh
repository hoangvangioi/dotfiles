#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# Always operate relative to the repo root, no matter where the script is called from.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# ============================================
# Configuration
# ============================================
readonly CONFIG_DIR="${HOME}/.config"
readonly SCRIPTS_DIR="/usr/local/bin"
DATE=$(date +%Y%m%d_%H%M%S)
readonly DATE
TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
readonly LOG_FILE="${TEMP_DIR}/setup_${DATE}.log"
readonly FINAL_LOG="${HOME}/.local/share/arch-setup/setup_${DATE}.log"

# ============================================
# Colors (more compatible)
# ============================================
if [[ -t 1 ]]; then
    readonly GREEN='\e[0;32m'
    readonly YELLOW='\e[1;33m'
    readonly RED='\e[0;31m'
    readonly BLUE='\e[0;34m'
    readonly NO_COLOR='\e[0m'
else
    readonly GREEN=''
    readonly YELLOW=''
    readonly RED=''
    readonly BLUE=''
    readonly NO_COLOR=''
fi

# ============================================
# Logging
# ============================================
_log() {
    local level="$1"
    local color="$2"
    local msg="$3"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_line="[${timestamp}] [${level}] ${msg}"

    # Console output
    echo -e "${color}[${level}] ${msg}${NO_COLOR}"

    # File output (check if log file still exists)
    if [[ -f "${LOG_FILE}" ]]; then
        echo "${log_line}" >>"${LOG_FILE}"
    fi
}

log_info()  { _log "*" "${GREEN}" "$1"; }
log_warn()  { _log "!" "${YELLOW}" "$1"; }
log_error() { _log "✗" "${RED}" "$1" >&2; }
log_debug() { _log "→" "${BLUE}" "$1"; }

# ============================================
# Save log before cleanup
# ============================================
save_log() {
    if [[ -f "${LOG_FILE}" ]]; then
        mkdir -p "$(dirname "${FINAL_LOG}")"
        cp "${LOG_FILE}" "${FINAL_LOG}"
        echo "${FINAL_LOG}"
    fi
}

# ============================================
# Cleanup & Traps
# ============================================
cleanup() {
    local exit_code=$?

    # Save log before deleting TEMP_DIR
    local saved_log
    saved_log=$(save_log)

    if [[ -d "${TEMP_DIR}" ]]; then
        sudo rm -rf "${TEMP_DIR}" 2>/dev/null || rm -rf "${TEMP_DIR}" 2>/dev/null || true
    fi

    if [[ -n "${SUDO_PID:-}" ]] && kill -0 "${SUDO_PID}" 2>/dev/null; then
        kill "${SUDO_PID}" 2>/dev/null || true
    fi

    # Log message was saved
    if [[ -n "${saved_log:-}" ]]; then
        echo -e "\e[0;34m[→] Log saved to: ${saved_log}\e[0m" >&2
    fi

    exit "${exit_code}"
}
trap cleanup EXIT INT TERM HUP

# ============================================
# Sudo Management
# ============================================
refresh_sudo() {
    log_info "Starting sudo timestamp refresh..."
    (
        while true; do
            sudo -n true 2>/dev/null || exit 0
            sleep 50
        done
    ) &
    SUDO_PID=$!
}

# ============================================
# Prerequisites
# ============================================
ensure_dialog() {
    if ! command -v dialog &>/dev/null; then
        log_info "Installing dialog..."
        sudo pacman -S --noconfirm --needed dialog
    fi
}

# ============================================
# System Update
# ============================================
system_update() {
    log_info "Updating system..."
    # Full upgrade including the keyring; avoids leaving the system in a
    # partial-upgrade state (the old -Sy + -Syu sequence could do that).
    sudo pacman -Syu --noconfirm --needed archlinux-keyring
    sudo pacman -S --noconfirm --needed base-devel wget git curl
}

# ============================================
# AUR Helper (yay)
# ============================================
install_yay() {
    if command -v yay &>/dev/null; then
        log_info "yay is already installed."
        return 0
    fi

    log_info "Installing yay..."
    local yay_dir="${TEMP_DIR}/yay"
    git clone --depth 1 "https://aur.archlinux.org/yay.git" "${yay_dir}"
    (cd "${yay_dir}" && makepkg -si --noconfirm)
    log_info "yay installed successfully."
}

# ============================================
# Package Installation
# ============================================
PACMAN_PKGS=(
    # ── Core ──
    base-devel curl git wget

    # ── Audio (PipeWire) ──
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    alsa-utils pulsemixer

    # ── Bluetooth ──
    bluez bluez-utils

    # ── Xorg & Display ──
    xorg xorg-xinit xclip

    # ── Terminal & Shell ──
    alacritty zsh starship zoxide
    zsh-autosuggestions zsh-syntax-highlighting zsh-completions
    zsh-history-substring-search

    # ── Window Manager ──
    i3-wm

    # ── Compositor ──
    picom

    # ── Launcher & Bar ──
    rofi polybar

    # ── File Manager ──
    nemo yazi

    # ── Browser ──
    firefox

    # ── Notifications ──
    dunst libnotify

    # ── Wallpaper, Screenshot & Recording ──
    feh maim slop ffmpeg flameshot xdotool

    # ── System Monitor ──
    btop cava

    # ── Network ──
    networkmanager network-manager-applet openvpn networkmanager-openvpn
    networkmanager-dmenu wmctrl

    # ── Fonts ──
    ttf-jetbrains-mono-nerd ttf-iosevka-nerd ttf-nerd-fonts-symbols-mono
    noto-fonts noto-fonts-cjk noto-fonts-emoji papirus-icon-theme

    # ── Utilities ──
    bc jq ripgrep fd fzf bat eza tree pacman-contrib xdg-utils reflector

    # ── Power & Hardware ──
    upower acpi brightnessctl gammastep

    # ── Screen Lock ──
    xss-lock

    # ── GTK / Audio / Display GUI ──
    lxappearance pavucontrol arandr

    # ── Firmware ──
    sof-firmware

    # ── Archive ──
    unzip 7zip

    # ── Others ──
    ntfs-3g vnstat

    # ── Editors & Documents ──
    neovim zathura zathura-pdf-mupdf

    # ── Media ──
    playerctl

    # ── i3 helpers ──
    autotiling

    # ── System Info ──
    fastfetch
)

install_pkgs() {
    log_info "Installing packages with pacman..."
    sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"
}

AUR_PKGS=(
    # ── Zsh ──
    zsh-you-should-use

    # ── i3 Ecosystem ──
    i3-resurrect i3lock-color

    # ── Screenshot & Recording ──
    ffcast

    # ── Music ──
    spotify

    # ── Dracula Theme & Icons ──
    dracula-gtk-theme dracula-icons-theme

    # ── Cursor & Icon Fonts ──
    bibata-cursor-theme-bin
)

install_aur_pkgs() {
    if ! command -v yay &>/dev/null; then
        log_error "yay is not installed. Select 'Install yay (AUR helper)' first."
        return 1
    fi

    log_info "Installing packages with yay..."

    # i3lock-color provides/conflicts with i3lock; remove the old package
    # first so a previous installation does not block the upgrade.
    sudo pacman -Rns --noconfirm i3lock 2>/dev/null || true

    yay -S --noconfirm --needed "${AUR_PKGS[@]}"
}

# ============================================
# Backup
# ============================================
CONFIG_DIRS=(alacritty btop cava dunst fastfetch fcitx5 gammastep gtk-3.0 gtk-4.0 i3 nvim picom polybar rofi zathura)

create_backup() {
    log_info "Creating backup of existing configs..."
    local backup_dir="${CONFIG_DIR}/backup_${DATE}"
    mkdir -p "${backup_dir}"

    for dir in "${CONFIG_DIRS[@]}"; do
        local src="${CONFIG_DIR}/${dir}"
        if [[ -d "${src}" ]]; then
            cp -a "${src}" "${backup_dir}/"
            log_info "${dir} configs backed up."
        fi
    done

    if [[ -d "${SCRIPTS_DIR}" ]]; then
        local scripts_backup="${backup_dir}/usr-local-bin"
        sudo cp -a "${SCRIPTS_DIR}" "${scripts_backup}"
        sudo chown -R "$(id -u):$(id -g)" "${scripts_backup}" 2>/dev/null || true
        log_info "Scripts directory backed up to ${scripts_backup}"
    fi

    # Dotfiles that live outside ~/.config
    for file in .zshrc .xprofile; do
        if [[ -f "${HOME}/${file}" ]]; then
            cp -a "${HOME}/${file}" "${backup_dir}/"
            log_info "${file} backed up."
        fi
    done

    log_info "All backups saved to: ${backup_dir}"
}

# ============================================
# Default Directories
# ============================================
create_default_directories() {
    log_info "Creating default directories..."
    mkdir -p "${HOME}/.config" "${HOME}/Pictures/wallpapers" "${HOME}/Pictures/screenshots"
    sudo mkdir -p /usr/local/bin /usr/share/themes
}

# ============================================
# File Copying
# ============================================
copy_files() {
    log_info "Copying files..."

    if [[ -d "./config" ]]; then
        cp -r ./config/* "${CONFIG_DIR}/"
        log_info "Config files copied."
    else
        log_warn "Config directory not found, skipping."
    fi

    if [[ -d "./bin" ]]; then
        sudo mkdir -p "${SCRIPTS_DIR}"
        sudo cp -r ./bin/* "${SCRIPTS_DIR}/"
        sudo find "${SCRIPTS_DIR}" -maxdepth 1 -type f -exec chmod +x {} +
        log_info "Scripts copied and made executable."
    else
        log_warn "Bin directory not found, skipping."
    fi

    if [[ -d "./wallpapers" ]]; then
        cp -r ./wallpapers/* "${HOME}/Pictures/wallpapers/"
        log_info "Wallpapers copied."
    else
        log_warn "Wallpapers directory not found, skipping."
    fi

    # Dotfiles
    local dotfiles=(.zshrc .xprofile)
    for file in "${dotfiles[@]}"; do
        if [[ -f "./${file}" ]]; then
            cp "./${file}" "${HOME}/"
            log_info "${file} copied."
        fi
    done
}

# ============================================
# GTK Theme (Dracula)
# ============================================
install_gtk_theme() {
    if ! command -v yay &>/dev/null; then
        log_error "yay is not installed. Select 'Install yay (AUR helper)' first."
        return 1
    fi

    log_info "Installing Dracula GTK theme and icons..."
    yay -S --noconfirm --needed dracula-gtk-theme dracula-icons-theme bibata-cursor-theme-bin

    # Copy GTK-4.0 assets for libadwaita apps
    if [[ -d "/usr/share/themes/Dracula" ]]; then
        mkdir -p "${CONFIG_DIR}/gtk-4.0"
        if [[ -f "/usr/share/themes/Dracula/gtk-4.0/gtk.css" ]]; then
            cp "/usr/share/themes/Dracula/gtk-4.0/gtk.css" "${CONFIG_DIR}/gtk-4.0/"
        fi
        if [[ -f "/usr/share/themes/Dracula/gtk-4.0/gtk-dark.css" ]]; then
            cp "/usr/share/themes/Dracula/gtk-4.0/gtk-dark.css" "${CONFIG_DIR}/gtk-4.0/"
        fi
        if [[ -d "/usr/share/themes/Dracula/assets" ]]; then
            mkdir -p "${CONFIG_DIR}/gtk-4.0"
            cp -r "/usr/share/themes/Dracula/assets" "${CONFIG_DIR}/gtk-4.0/"
        fi
        log_info "GTK-4.0 Dracula assets copied to ~/.config"
    fi

    # Set theme via gsettings if available
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "Dracula" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "Dracula" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice" 2>/dev/null || true
        log_info "Theme set via gsettings."
    fi

    log_info "Dracula theme installed successfully."
}

# ============================================
# Git Helper
# ============================================
git_clone_if_not_exists() {
    local repo_url="$1"
    local target_dir="$2"

    if [[ -d "${target_dir}/.git" ]]; then
        log_warn "$(basename "${target_dir}") already exists, skipping."
        return 0
    fi

    git clone --depth 1 "${repo_url}" "${target_dir}"
}

# ============================================
# Zsh (plain) + Starship
# ============================================
install_zsh() {
    log_info "Installing zsh, starship and plugins (pacman + AUR)..."
    sudo pacman -S --noconfirm --needed zsh starship zoxide \
        zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
        zsh-history-substring-search

    # zsh-you-should-use is AUR-only
    if command -v yay &>/dev/null; then
        yay -S --noconfirm --needed zsh-you-should-use
    else
        log_warn "yay not found — skipping zsh-you-should-use. Choose 'Install yay (AUR helper)' and run again."
    fi

    # zsh-autopair is AUR-only -git, so keep git clone (lighter than yay build)
    local data_plugins="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    mkdir -p "${data_plugins}"
    git_clone_if_not_exists "https://github.com/hlissner/zsh-autopair.git" \
        "${data_plugins}/zsh-autopair"

    log_info "Setting Zsh as default shell..."
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "${SHELL}" != "${zsh_path}" ]]; then
        chsh -s "${zsh_path}"
    fi

    # Remaining: old oh-my-zsh can be removed (not auto-removed)
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        log_warn "~/.oh-my-zsh still exists (no longer used in .zshrc). Remove it: rm -rf ~/.oh-my-zsh"
    fi
}

# ============================================
# Fcitx5 Bamboo
# ============================================
install_fcitx5_bamboo() {
    log_info "Installing fcitx5 and fcitx5-bamboo..."
    sudo pacman -S --noconfirm --needed fcitx5 fcitx5-bamboo fcitx5-gtk fcitx5-qt

    log_info "Deploying Fcitx5 configuration files..."
    mkdir -p "${HOME}/.config/fcitx5"

    cp -r "config/fcitx5/"* "${HOME}/.config/fcitx5/"
}

# ============================================
# SDDM Theme
# ============================================
install_sddm() {
    log_info "Installing SDDM theme..."
    # qt6-multimedia: Main.qml imports QtMultimedia (greeter crashes without it)
    # qt6-svg:        the icons in Assets/   |   qt6-5compat: NOT needed
    sudo pacman -S --noconfirm --needed sddm qt6-declarative qt6-svg qt6-multimedia qt6-virtualkeyboard

    if command -v systemctl &>/dev/null; then
        sudo systemctl enable sddm.service --now 2>/dev/null ||
            sudo systemctl enable sddm.service 2>/dev/null ||
            log_warn "could not enable sddm.service"
    fi

    # The theme lives on GitHub only, so fetch it, install it, drop the clone.
    local dir="${XDG_CACHE_HOME:-$HOME/.cache}/sddm-arch-mauve"
    rm -rf "$dir"
    if git clone -q --depth 1 https://github.com/hoangvangioi/sddm-arch-mauve.git "$dir"; then
        ( cd "$dir" && ./install.sh ) || { log_warn "theme install failed"; return 1; }
        rm -rf "$dir"
        log_info "SDDM theme installed."
    else
        log_warn "could not fetch the theme repo, skipping."
    fi
}

# ============================================
# GRUB Theme
# ============================================
install_grub_theme() {
    log_info "Installing GRUB Bootloader theme..."
    local grub_dir="${TEMP_DIR}/arch-grub-theme"
    git_clone_if_not_exists "https://github.com/hoangvangioi/arch-grub-theme.git" "${grub_dir}"

    if [[ -f "${grub_dir}/install.sh" ]]; then
        (cd "${grub_dir}" && ./install.sh)
        log_info "GRUB theme installed."
    else
        log_warn "GRUB theme install script not found."
    fi
}

# ============================================
# Enable Services
# ============================================
enable_services() {
    log_info "Enabling system services..."

    if command -v systemctl &>/dev/null; then
        sudo systemctl enable --now bluetooth.service 2>/dev/null || sudo systemctl enable bluetooth.service
        sudo systemctl enable --now NetworkManager.service 2>/dev/null || sudo systemctl enable NetworkManager.service
        sudo systemctl enable --now systemd-timesyncd.service 2>/dev/null || sudo systemctl enable systemd-timesyncd.service
        log_info "Core services enabled."
    fi

    # PipeWire user services
    if command -v systemctl &>/dev/null; then
        systemctl --user enable --now pipewire.service 2>/dev/null || true
        systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
        systemctl --user enable --now wireplumber.service 2>/dev/null || true
        log_info "PipeWire user services enabled."
    fi
}

# ============================================
# Error Handler
# ============================================
error_handler() {
    local line_no="$1"
    local error_code="$2"
    log_error "Error at line ${line_no}: exit code ${error_code}"
    log_error "Check log: ${LOG_FILE}"
}
trap 'error_handler ${LINENO} $?' ERR

# ============================================
# Main Dialog
# ============================================
main() {
    if [[ "${EUID}" -eq 0 ]]; then
        log_error "Do not run this script as root. Use a regular user with sudo access."
        exit 1
    fi

    if ! sudo -v; then
        log_error "Sudo access required."
        exit 1
    fi

    refresh_sudo
    ensure_dialog

    local cmd=(
        dialog --clear --separate-output
        --backtitle "Arch Linux Setup"
        --title "Setup Options"
        --checklist "Select tasks to perform (Space to select, Enter to confirm):" 25 80 16
    )

    local options=(
        1 "System update" on
        2 "Install yay (AUR helper)" on
        3 "Install basic packages" off
        4 "Install AUR packages" off
        5 "Create default directories" off
        6 "Create backup of existing configs" off
        7 "Copy configs and scripts" off
        8 "Install Dracula GTK theme" off
        9 "Install Zsh and plugins" off
        10 "Install Fcitx5 Bamboo" off
        11 "Install SDDM theme" off
        12 "Install GRUB Bootloader theme" off
        13 "Enable system services" off
    )

    local choices
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) || {
        log_info "Setup cancelled by user."
        exit 0
    }

    clear

    for choice in ${choices}; do
        case "${choice}" in
            1) system_update ;;
            2) install_yay ;;
            3) install_pkgs ;;
            4) install_aur_pkgs ;;
            5) create_default_directories ;;
            6) create_backup ;;
            7) copy_files ;;
            8) install_gtk_theme ;;
            9) install_zsh ;;
            10) install_fcitx5_bamboo ;;
            11) install_sddm ;;
            12) install_grub_theme ;;
            13) enable_services ;;
        esac
    done

    # Copy log out before cleanup
    local saved_log
    saved_log=$(save_log)

    log_info "Setup complete!"
    if [[ -n "${saved_log:-}" ]]; then
        log_info "Log saved to: ${saved_log}"
    fi
    log_info "Please reboot your system to apply all changes."
}

main "$@"
