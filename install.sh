#!/bin/bash

set -e

# Define variables
CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="/usr/local/bin"
DATE=$(date +%s)

GREEN='\033[0;32m'
NO_COLOR='\033[0m'

# Install dialog if not already installed
sudo pacman -S --noconfirm --needed dialog

# Function to update the system
system_update() {
    echo -e "${GREEN}[*] Updating system...${NO_COLOR}"
    sudo pacman -Sy --noconfirm archlinux-keyring
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm --needed base-devel wget git curl
}

# Function to install yay
install_yay() {
    if ! command -v yay &>/dev/null; then
        echo -e "${GREEN}[*] Installing yay...${NO_COLOR}"
        git clone "https://aur.archlinux.org/yay.git" "$HOME/.srcs/yay"
        (cd "$HOME/.srcs/yay" && makepkg -si --noconfirm)
    else
        echo -e "${GREEN}[*] yay is already installed.${NO_COLOR}"
    fi
}

# Function to install basic packages
install_pkgs() {
    echo -e "${GREEN}[*] Installing packages with pacman...${NO_COLOR}"
    sudo pacman -S --noconfirm --needed \
        acpi alsa-utils base-devel curl git \
        pulseaudio pulseaudio-alsa xorg xorg-xinit alacritty \
        btop dunst feh firefox i3-wm libnotify nemo neofetch \
        bc xf86-video-intel bluez bluez-utils pulseaudio-bluetooth \
        bluez-libs openvpn networkmanager-openvpn networkmanager \
        network-manager-applet
}

# Function to install AUR packages
install_aur_pkgs() {
    echo -e "${GREEN}[*] Installing packages with yay...${NO_COLOR}"
    yay -S --noconfirm --needed \
        i3lock i3-resurrect ffcast dhcpcd iwd ntfs-3g \
        ntp pulsemixer vnstat light upower maim redshift \
        spotify playerctl ttf-jetbrains-mono-nerd neovim \
        polybar ranger rofi zathura zathura-pdf-mupdf \
        visual-studio-code-bin papirus-icon-theme

    echo -e "${GREEN}[*] Installing i3lock-color...${NO_COLOR}"
    git clone https://github.com/Raymo111/i3lock-color.git
    (cd i3lock-color && ./install-i3lock-color.sh)
    rm -rf i3lock-color
}

# Function to create backups of existing configurations
create_backup() {
    echo -e "${GREEN}[*] Creating backup of existing configs...${NO_COLOR}"
    for dir in alacritty btop Code dunst gtk-3.0 i3 neofetch nvim polybar ranger rofi zathura; do
        if [ -d "$CONFIG_DIR/$dir" ]; then
            mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/${dir}_$DATE"
            echo "$dir configs backed up."
        fi
    done

    if [ -d "$SCRIPTS_DIR" ]; then
        sudo mv "$SCRIPTS_DIR" "$SCRIPTS_DIR_$DATE"
        echo "Scripts directory backed up."
    fi
}

# Function to create default directories
create_default_directories() {
    echo -e "${GREEN}[*] Creating default directories...${NO_COLOR}"
    mkdir -p "$HOME/.config" "$HOME/Pictures/wallpapers"
    sudo mkdir -p /usr/local/bin /usr/share/themes
}

# Function to copy configuration and script files
copy_files() {
    echo -e "${GREEN}[*] Copying files...${NO_COLOR}"
    [ -d "./config" ] && cp -r ./config/* "$CONFIG_DIR"
    if [ -d "./bin" ]; then
        sudo cp -r ./bin/* "$SCRIPTS_DIR"
        sudo chmod +x "$SCRIPTS_DIR"/*
    fi
    [ -d "./wallpapers" ] && cp -r ./wallpapers/* "$HOME/Pictures/wallpapers"
}

# Function to install GTK theme
install_gtk_theme() {
    echo -e "${GREEN}[*] Installing GTK theme...${NO_COLOR}"
    yay -S --noconfirm --needed bibata-cursor-theme-bin
    wget -q https://github.com/EliverLara/Sweet/releases/download/v5.0/Sweet-Dark-v40.tar.xz
    tar xvf Sweet-Dark-v40.tar.xz
    sudo mkdir -p /usr/share/themes/Sweet-Dark-v40
    sudo cp -r ./Sweet-Dark-v40/{assets,gtk-3.0,gtk-4.0,index.theme} /usr/share/themes/Sweet-Dark-v40
    rm -rf ./Sweet-Dark-v40*
    echo -e "${GREEN}[*] Installation complete.${NO_COLOR}"
}

# Function to install Zsh and plugins
install_zsh() {
    echo -e "${GREEN}[*] Installing zsh and oh-my-zsh...${NO_COLOR}"
    yay -S --noconfirm --needed zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/you-should-use
    git clone https://github.com/fdellwing/zsh-bat.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-bat
    cp ./.zshrc ~/
    echo -e "${GREEN}[*] Setting Zsh as default shell...${NO_COLOR}"
    chsh -s "$(which zsh)"
    sudo chsh -s "$(which zsh)"
}

# Function to install Ibus Bamboo
install_ibus_bamboo() {
    echo -e "${GREEN}[*] Installing ibus-bamboo...${NO_COLOR}"
    yay -S --noconfirm --needed ibus ibus-bamboo-git
    dconf load /desktop/ibus/ <"$HOME/.config/ibus/ibus.dconf"
    sudo tee -a /etc/profile <<END

# Ibus bamboo
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT4_IM_MODULE=ibus
export CLUTTER_IM_MODULE=ibus
export GLFW_IM_MODULE=ibus

if ! pgrep -x "ibus-daemon" > /dev/null; then
    ibus-daemon -drx > /var/log/ibus-daemon.log 2>&1 &
fi
END
}

# Function to install VSCode extensions
install_vsc() {
    echo -e "${GREEN}[*] Installing VSCode extensions...${NO_COLOR}"
    code --install-extension zhuangtongfa.Material-theme
    code --install-extension dracula-theme.theme-dracula
    code --install-extension pkief.material-icon-theme
    code --install-extension visualstudioexptteam.intellicode-api-usage-examples
    code --install-extension visualstudioexptteam.vscodeintellicode
}

# Function to install SDDM theme
install_sddm() {
    echo -e "${GREEN}[*] Installing SDDM theme...${NO_COLOR}"
    yay -S --noconfirm --needed qt6-5compat qt6-declarative qt6-svg sddm
    sudo systemctl enable sddm.service
    sudo cp -r sddm-arch-theme /usr/share/sddm/themes
    echo "[Theme]
Current=sddm-arch-theme" | sudo tee /etc/sddm.conf
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
    esac
done

echo -e "${GREEN}[*] Setup complete.${NO_COLOR}"
