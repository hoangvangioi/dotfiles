#!/usr/bin/env bash
set -euo pipefail

# Define variables
readonly CONFIG_DIR="$HOME/.config"
readonly SCRIPTS_DIR="/usr/local/bin"
DATE=$(date +%s)
readonly DATE
TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NO_COLOR='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[*] $1${NO_COLOR}"
}

log_warn() {
    echo -e "${YELLOW}[!] $1${NO_COLOR}"
}

log_error() {
    echo -e "${RED}[✗] $1${NO_COLOR}" >&2
}

# Cleanup on exit
cleanup() {
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Refresh sudo timestamp
refresh_sudo() {
    while true; do
        sudo -v
        sleep 50
    done &
    SUDO_PID=$!
    trap 'kill $SUDO_PID 2>/dev/null; cleanup' EXIT
}

# Install dialog if not already installed
sudo pacman -S --noconfirm --needed dialog

# Function to update the system
system_update() {
    log_info "Updating system..."
    sudo pacman -Sy --noconfirm archlinux-keyring
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm --needed base-devel wget git curl
}

# Function to install yay
install_yay() {
    if ! command -v yay &>/dev/null; then
        log_info "Installing yay..."
        local yay_dir="$TEMP_DIR/yay"
        git clone "https://aur.archlinux.org/yay.git" "$yay_dir"
        (cd "$yay_dir" && makepkg -si --noconfirm)
    else
        log_info "yay is already installed."
    fi
}

# Function to install basic packages
install_pkgs() {
    log_info "Installing packages with pacman..."
    sudo pacman -S --noconfirm --needed \
        acpi alsa-utils base-devel curl git \
        pulseaudio pulseaudio-alsa xorg xorg-xinit alacritty \
        btop dunst feh firefox i3-wm libnotify nemo \
        bc xf86-video-intel bluez bluez-utils pulseaudio-bluetooth \
        bluez-libs openvpn networkmanager-openvpn networkmanager \
        network-manager-applet
}

# Function to install AUR packages
install_aur_pkgs() {
    log_info "Installing packages with yay..."
    yay -S --noconfirm --needed \
        i3lock i3-resurrect ffcast dhcpcd iwd ntfs-3g \
        ntp pulsemixer vnstat light upower maim redshift \
        spotify playerctl ttf-jetbrains-mono-nerd neovim \
        polybar ranger rofi zathura zathura-pdf-mupdf \
        visual-studio-code-bin papirus-icon-theme neofetch

    log_info "Installing i3lock-color..."
    local i3lock_dir="$TEMP_DIR/i3lock-color"
    git clone https://github.com/Raymo111/i3lock-color.git "$i3lock_dir"
    (cd "$i3lock_dir" && ./install-i3lock-color.sh)
}

# Function to create backups of existing configurations
create_backup() {
    log_info "Creating backup of existing configs..."
    local dirs=(alacritty btop Code dunst gtk-3.0 i3 neofetch nvim polybar ranger rofi zathura)
    
    for dir in "${dirs[@]}"; do
        if [ -d "$CONFIG_DIR/$dir" ]; then
            mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/${dir}_$DATE"
            log_info "$dir configs backed up."
        fi
    done

    if [ -d "$SCRIPTS_DIR" ]; then
        sudo mv "$SCRIPTS_DIR" "${SCRIPTS_DIR}_$DATE"
        log_info "Scripts directory backed up."
    fi
}

# Function to create default directories
create_default_directories() {
    log_info "Creating default directories..."
    mkdir -p "$HOME/.config" "$HOME/Pictures/wallpapers"
    sudo mkdir -p /usr/local/bin /usr/share/themes
}

# Function to copy configuration and script files
copy_files() {
    log_info "Copying files..."
    
    if [ -d "./config" ]; then
        cp -r ./config/* "$CONFIG_DIR"
        log_info "Config files copied."
    else
        log_warn "Config directory not found, skipping."
    fi
    
    if [ -d "./bin" ]; then
        sudo cp -r ./bin/* "$SCRIPTS_DIR"
        sudo chmod +x "$SCRIPTS_DIR"/*
        log_info "Scripts copied and made executable."
    else
        log_warn "Bin directory not found, skipping."
    fi
    
    if [ -d "./wallpapers" ]; then
        cp -r ./wallpapers/* "$HOME/Pictures/wallpapers"
        log_info "Wallpapers copied."
    else
        log_warn "Wallpapers directory not found, skipping."
    fi
    
    # Copy dotfiles
    [ -f "./.zshrc" ] && cp ./.zshrc ~/ && log_info ".zshrc copied."
    [ -f "./.xprofile" ] && cp ./.xprofile ~/ && log_info ".xprofile copied."
}

# Function to install GTK theme
install_gtk_theme() {
    log_info "Installing GTK theme..."
    yay -S --noconfirm --needed bibata-cursor-theme-bin
    
    local theme_dir="$TEMP_DIR/sweet-theme"
    mkdir -p "$theme_dir"
    cd "$theme_dir" || return 1
    
    wget -q https://github.com/EliverLara/Sweet/releases/download/v5.0/Sweet-Dark-v40.tar.xz
    tar xf Sweet-Dark-v40.tar.xz
    sudo mkdir -p /usr/share/themes/Sweet-Dark-v40
    sudo cp -r ./Sweet-Dark-v40/{assets,gtk-3.0,gtk-4.0,index.theme} /usr/share/themes/Sweet-Dark-v40
    
    cd - >/dev/null || return 1
    log_info "GTK theme installed successfully."
}

# Helper function to clone git repo if not exists
git_clone_if_not_exists() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [ ! -d "$target_dir" ]; then
        git clone "$repo_url" "$target_dir"
    else
        log_warn "$(basename "$target_dir") already exists, skipping."
    fi
}

# Function to install Zsh and plugins
install_zsh() {
    log_info "Installing zsh and oh-my-zsh..."
    yay -S --noconfirm --needed zsh
    
    # Install oh-my-zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_warn "oh-my-zsh already installed, skipping."
    fi
    
    # Install plugins
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    git_clone_if_not_exists "https://github.com/zsh-users/zsh-autosuggestions" "$custom_dir/plugins/zsh-autosuggestions"
    git_clone_if_not_exists "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$custom_dir/plugins/zsh-syntax-highlighting"
    git_clone_if_not_exists "https://github.com/MichaelAquilina/zsh-you-should-use.git" "$custom_dir/plugins/you-should-use"
    git_clone_if_not_exists "https://github.com/fdellwing/zsh-bat.git" "$custom_dir/plugins/zsh-bat"
    
    # Set Zsh as default shell
    log_info "Setting Zsh as default shell..."
    local zsh_path
    zsh_path="$(command -v zsh)"
    chsh -s "$zsh_path"
    sudo chsh -s "$zsh_path"
}

# Function to install Ibus Bamboo
install_ibus_bamboo() {
    log_info "Installing ibus-bamboo..."
    yay -S --noconfirm --needed ibus ibus-bamboo-git
    
    # Load ibus config if exists
    if [ -f "$HOME/.config/ibus/ibus.dconf" ]; then
        if command -v dconf &>/dev/null; then
            dconf load /desktop/ibus/ <"$HOME/.config/ibus/ibus.dconf"
            log_info "IBus config loaded."
        else
            log_warn "dconf command not found, skipping config load."
        fi
    else
        log_warn "ibus.dconf not found, skipping dconf load."
    fi
}

# Function to install VSCode extensions
install_vsc() {
    if ! command -v code &>/dev/null; then
        log_error "VSCode is not installed. Install it first."
        return 1
    fi
    
    log_info "Installing VSCode extensions..."
    local extensions=(
        "zhuangtongfa.Material-theme"
        "dracula-theme.theme-dracula"
        "pkief.material-icon-theme"
        "visualstudioexptteam.intellicode-api-usage-examples"
        "visualstudioexptteam.vscodeintellicode"
    )
    
    for ext in "${extensions[@]}"; do
        code --install-extension "$ext"
    done
    log_info "VSCode extensions installed."
}

# Function to install SDDM theme
install_sddm() {
    log_info "Installing SDDM theme..."
    yay -S --noconfirm --needed qt6-5compat qt6-declarative qt6-svg sddm
    
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable sddm.service
        log_info "SDDM service enabled."
    else
        log_warn "systemctl not found, skipping service enable."
    fi
    
    if [ -d "sddm-arch-theme" ]; then
        sudo cp -r sddm-arch-theme /usr/share/sddm/themes
        echo "[Theme]
Current=sddm-arch-theme" | sudo tee /etc/sddm.conf >/dev/null
        log_info "SDDM theme installed."
    else
        log_warn "sddm-arch-theme directory not found, skipping."
    fi
}

# Function to install Grub Bootloader theme
install_grub_theme() {
    log_info "Installing Grub Bootloader theme..."
    local grub_dir="$TEMP_DIR/arch-grub-theme"
    git clone https://github.com/hoangvangioi/arch-grub-theme.git "$grub_dir"
    (cd "$grub_dir" && ./install.sh)
    log_info "Grub theme installed."
}

# Display dialog to select tasks
cmd=(dialog --clear --separate-output --checklist "Select tasks to perform (press space to select).\\n\
Checked options are required for proper installation.\\nDo not uncheck if you are unsure." 21 80 15)

options=(
    1 "System update" on
    2 "Install yay (AUR helper)" on
    3 "Install basic packages" off
    4 "Install AUR packages" off
    5 "Create default directories" off
    6 "Create backup of existing configs" off
    7 "Copy configs and scripts" off
    8 "Install GTK theme" off
    9 "Install Zsh and plugins" off
    10 "Install Ibus Bamboo" off
    11 "Install VSCode extensions" off
    12 "Install SDDM theme" off
    13 "Install Grub Bootloader theme" off
)

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

clear

# Execute selected tasks
for choice in $choices; do
    case $choice in
    1) system_update ;;
    2) install_yay ;;
    3) install_pkgs ;;
    4) install_aur_pkgs ;;
    5) create_default_directories ;;
    6) create_backup ;;
    7) copy_files ;;
    8) install_gtk_theme ;;
    9) install_zsh ;;
    10) install_ibus_bamboo ;;
    11) install_vsc ;;
    12) install_sddm ;;
    13) install_grub_theme ;;
    esac
done

log_info "Setup complete!"
log_info "Please reboot your system to apply all changes."
