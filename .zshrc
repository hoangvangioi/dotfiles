# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="cloud"

plugins=(
    git
    z
    eza
    fzf
    bgnotify
    colored-man-pages
    zsh-bat
    zsh-autopair
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Aliases
alias mirrors="sudo reflector -c VN,SG,HK,TW,TH,JP,CN -a 12 -p https -l 200 -f 20 --sort rate --save /etc/pacman.d/mirrorlist"
alias tree='eza --icons -a --tree --color-scale --group-directories-first'
alias treell='eza --icons -a -l --tree --color-scale --group-directories-first'
alias ls='eza --icons --color-scale --group-directories-first'
alias la='eza --icons --color-scale -a --group-directories-first'
alias ll='eza --icons --color-scale -l --group-directories-first'
alias lla='eza --icons --color-scale -la --group-directories-first'
