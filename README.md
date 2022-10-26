# Dotfiles  

The **Arch Linux** & **i3wm** dotfiles! 

## Information

- **OS:** [Arch Linux](https://archlinux.org)
- **WM:** [i3-gaps](https://github.com/Airblader/i3)
- **Terminal:** [alacritty](https://github.com/alacritty/alacritty)
- **Bar:** [polybar](https://github.com/polybar/polybar)
- **Shell:** [zsh](https://www.zsh.org/)
- **Application Launcher:** [rofi](https://github.com/davatorium/rofi)
- **Notification Deamon:** [dunst](https://github.com/dunst-project/dunst)

<details>
<summary><b>
Detailed information and dependencies
</b></summary>

### Info

**Editor:** [neovim](https://github.com/neovim/neovim)
**Lockscreen:** [i3lock-color](https://github.com/Raymo111/i3lock-color)
**Display Manager:** [sddm](https://github.com/sddm/sddm)
**File manager:** [ranger](https://github.com/ranger/ranger) / [nemo](https://github.com/linuxmint/nemo)
**Monitor of Resources:** [btop](https://github.com/aristocratos/btop)

### Used themes

**Shell Framework:** [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh)    
**Neovim Theme:** [AstroNvim](https://github.com/kabinspace/AstroVim)    
**Icons:** [Papirus dark](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)    
**Display Manager Theme:** [Sddm-flower-theme](https://github.com/Keyitdev/sddm-flower-theme)    
	
### Fonts
	
**Icons:** [Feather](https://github.com/AT-UI/feather-font/blob/master/src/fonts/feather.ttf)    
**Interface Font:** [Open sans](https://fonts.google.com/specimen/Open+Sans#standard-styles)    
**Monospace Font:** [Roboto mono](https://fonts.google.com/specimen/Roboto+Mono#standard-styles)    
**Polybar Font:** [Iosevka nerd font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Iosevka)

### Dependencies

**Base:** acpi alsa-utils base-devel curl git pulseaudio pulseaudio-alsa xorg xorg-xinit 

**Required:** alacritty btop code dunst feh ffcast firefox i3-gaps i3lock-color i3-resurrect libnotify light mpc mpd ncmpcpp nemo neofetch neovim pacman-contrib papirus-icon-theme polybar ranger rofi scrot slop xclip zsh

**Sddm:** qt5-graphicaleffects qt5-quickcontrols2 qt5-svg sddm

**Emoji:** fonts: noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

</details>

## Installation

### Using install script 

Clone the repository.
```sh
git clone https://www.github.com/hoangvangioi/dotfiles.git
cd dotfiles
chmod +x install-on-arch.sh
./install-on-arch.sh
```

### Manual Installation

1. Clone this repository.
    ```sh
    git clone https://www.github.com/hoangvangioi/dotfiles.git
    ```

2. Install an AUR helper (for example, `yay` in `"$HOME"/.srcs`).
    ```sh
    git clone https://aur.archlinux.org/yay.git "$HOME"/.srcs/yay
	cd "$HOME"/.srcs/yay/ && makepkg -si
    ```

3. Install dependencies.
    ```sh
    yay -S --needed acpi alsa-utils base-devel curl git pulseaudio pulseaudio-alsa xorg xorg-xinit alacritty btop code dunst feh ffcast firefox i3-gaps i3lock-color i3-resurrect libnotify light nemo neofetch neovim pacman-contrib papirus-icon-theme polybar ranger rofi scrot slop xclip zsh
    ```

4. Create default directories.
    ```sh
    mkdir -p "$HOME"/.config
    mkdir -p  /usr/local/bin
    mkdir -p  /usr/share/themes
    mkdir -p "$HOME"/Pictures/wallpapers
    ```

5. Copy configs, scripts, fonts, wallpaper, zsh config.
    ```sh
    cp -r ./config/* "$HOME"/.config
    sudo cp -r ./scripts/* /usr/local/bin
    sudo cp -r ./fonts/* /usr/share/fonts
    cp -r ./wallpapers/* "$HOME"/Pictures/wallpapers
    sudo cp ./keyitdev.zsh-theme /usr/share/oh-my-zsh/custom/themes
    cp ./.zshrc "$HOME"
    ```

6. Make Light executable, set zsh as default shell, update nvim extensions, refresh font cache.
    ```sh
    sudo chmod +s /usr/bin/light
    chsh -s /bin/zsh
    sudo chsh -s /bin/zsh
    nvim +PackerSync
    fc-cache -fv
    ```

8. Install sddm flower theme.
    ```sh
    sudo cp -r ~/dotfiles/sddm-flower-theme /usr/share/sddm/themes/sddm-flower-theme
    sudo cp /usr/share/sddm/themes/sddm-flower-theme/Fonts/* /usr/share/fonts/
    echo "[Theme]
    Current=sddm-flower-theme" | sudo tee /etc/sddm.conf
    ```

## Cheat sheet


<details>
<summary>Keybinds</summary>

These are the basic keybinds. Read through the [i3](./config/i3/config) config for more keybinds.

|        Keybind         |                 Function                 |
| ---------------------- | ---------------------------------------- |
| `Win + Enter`          | Launch terminal (alacritty)              |
| `Win + Shift + Q`      | Close window                             |
| `Win + Q`              | Stacking layout                          |
| `Win + W`              | Tabbed layout                            |
| `Win + E`              | Default layout                           |
| `Win + R`              | Resize mode                              |
| `Win + T`              | Restore layout                           |
| `Win + Y`              | Save layout                              |
| `Win + A`              | Rofi open windows menu                   |
| `Win + S`              | Rofi full menu                           |
| `Win + D`              | Rofi menu                                |
| `Win + Z`              | Rofi bookmarks                           |
| `Win + X`              | Rofi powermenu                           |
| `Win + C`              | Rofi screenshot script                   |
| `Win + G`              | Gaps settings                            |
| `Win + V`              | Set vertical orientation                 |
| `Win + H`              | Set horizontal orientation               |
| `Win + I`              | Lock screen                              |
| `Win + O`              | Show polybar                             |
| `Win + P`              | Hide polybar                             |
| `Win + B`              | Move workspace to another monitor        |
| `Win + N`              | Dual monitor mode                        |
| `Win + M`              | Single monitor mode                      |
| `Win + arrows (jkl;)`  | Resizing, moving windows                 |
| `Win + Shift + E`      | Exit i3                                  |
| `Win + Shift + R`      | Restart i3                               |

Note: `Win` refers to the `Super/Mod` key.

</details>

<details>
<summary>Colors</summary>

|        Color           |                 Hex code                 |
| ---------------------- | ---------------------------------------- |
|  background            | #1b1b25                                  |
|  background 2          | #282A36                                  |
|  background 3          | #16161e                                  |
|  border                | #343746                                  |
|  foreground            | #dedede                                  |
|  white                 | #eeffff                                  |
|  black                 | #15121c                                  |
|  red                   | #cb5760                                  |
|  green                 | #999f63                                  |
|  yellow                | #d4a067                                  |
|  blue                  | #6c90a8                                  |
|  purple                | #776690                                  |
|  cyan                  | #528a9b                                  |
|  pink                  | #ffa8c5                                  |
|  orange                | #c87c3e                                  |

</details>