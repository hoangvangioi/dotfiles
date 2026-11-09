# ~/.zshrc — plain Zsh + Starship
# Plugins: pacman (main), AUR (zsh-you-should-use), git clone (zsh-autopair)

# ── Environment ──────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESSHISTFILE=-        # keep $HOME clean
export LANG=en_US.UTF-8
export MANPATH="/usr/local/man${MANPATH:+:$MANPATH}"

typeset -U path PATH         # deduplicate
path=("$HOME/.local/bin" "$HOME/bin" $path)
export PATH

# Bat as pager for man pages + backticks-colored cat replacement
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

# ── History ──────────────────────────────────────────────────
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt share_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks
setopt hist_verify extended_history hist_expire_dups_first
setopt hist_no_functions

# ── Options ──────────────────────────────────────────────────
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent
setopt correct interactive_comments
setopt extended_glob numeric_glob_sort globdots
setopt no_beep no_flow_control          # don't trap Ctrl+Q/Ctrl+S

# ── Keymap ───────────────────────────────────────────────────
# Must be set BEFORE loading plugins: `bindkey -e` copies the
# emacs keymap over `main`, and if placed at the end of the file
# it wipes bindings from fzf/autopair/history-substring-search.
bindkey -e

# Cover every terminal's sequence (alacritty/rxvt/konsole):
bindkey '\e[H'    beginning-of-line     # Home (alacritty)
bindkey '\e[F'    end-of-line           # End  (alacritty)
bindkey '\e[1~'   beginning-of-line     # Home (rxvt/konsole)
bindkey '\e[4~'   end-of-line           # End  (rxvt/konsole)
bindkey '\e[2~'   overwrite-mode        # Insert
bindkey '\e[3~'   delete-char           # Delete (forward)
bindkey '\e[3;3~' kill-word             # Alt+Delete

# ── Completion ───────────────────────────────────────────────
# zsh-completions must be in fpath BEFORE compinit runs
[[ -d /usr/share/zsh/plugins/zsh-completions ]] \
    && fpath+=(/usr/share/zsh/plugins/zsh-completions/src)

autoload -Uz compinit add-zsh-hook

# Skip the security check when the zcompdump was rebuilt today (faster)
_zdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_zdump"
_if_today=$(date -r "${_zdump}/.zcompdump" +%j 2>/dev/null)
_day=$(date +%j)
if [[ "$_if_today" == "$_day" ]]; then
    compinit -C -d "${_zdump}/.zcompdump"
else
    compinit -d "${_zdump}/.zcompdump"
fi
unset _zdump _day _if_today

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' descriptions format '── %d ──'
zstyle ':completion:*' special-dirs yes
zstyle ':completion:*' file-sort date
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack
zstyle ':completion:*:warnings' format "%BCouldn't find anything:%b"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=*'
# kill <TAB>: show pid + %cpu + %mem + command
zstyle ':completion:*:processes' command "ps -u $USER -o pid,%cpu,%mem,etime,command -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=30;31'
zstyle ':completion:*:killall:*' command "ps -u $USER -o pid,%cpu,%mem,etime,command -w"

# ── Aliases ──────────────────────────────────────────────────
# Global aliases
alias -g G='| rg'
alias -g L='| less'
alias -g C='| wc -l'
alias -g H='| head -20'
alias -g T='| tail -20'

alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias free='free -h'
alias v='nvim'

# git
alias gst='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -v -m'
alias gca='git commit -v --amend'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias glo='git log --oneline --decorate --color'
alias glog='git log --oneline --decorate --color --graph'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias grb='git rebase'
alias grst='git restore --staged'

# eza
alias ls='eza --icons --group-directories-first'
alias la='eza --icons -a --group-directories-first'
alias ll='eza --icons -l --time-style=long-iso --group-directories-first'
alias lla='eza --icons -la --time-style=long-iso --group-directories-first'
alias lg='eza --icons -la --git --time-style=long-iso --group-directories-first'
alias tree='eza --icons -a --tree --group-directories-first'
alias treell='eza --icons -la --tree --time-style=long-iso --group-directories-first'

alias mirrors="sudo reflector -c VN,SG,HK,TW,TH,JP,CN -a 12 -p https -l 200 -f 20 --sort rate --save /etc/pacman.d/mirrorlist"

# ── fzf ──────────────────────────────────────────────────────
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh

export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border --info=hidden
--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9,fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
--color=info:#6272a4,prompt:#50fa7b,pointer:#ff79c6,marker:#50fa7b,spinner:#ffb86c,header:#6272a4"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {} 2>/dev/null || head -100 {}' --preview-window right:60%:wrap"

# ── Plugins (order: autosuggestions → syntax-highlighting →
#    history-substring-search → autopair) ────────────────────

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6272a4'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    bindkey '^@' autosuggest-accept          # Ctrl+Space
fi

# zsh-you-should-use (AUR): remind about existing aliases
[[ -f /usr/share/zsh/plugins/zsh-you-should-use/zsh-you-should-use.plugin.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-you-should-use/zsh-you-should-use.plugin.zsh

# zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[path]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[unknown-command]='fg=red'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6272a4'
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zsh-history-substring-search (after syntax-highlighting)
if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

    HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=true
    HISTORY_SUBSTRING_SEARCH_FUZZY=true
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#bd93f9,fg=#282a36,bold'    # Dracula purple
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#ff5555,fg=#282a36'     # Dracula red

    bindkey '\e[A' history-substring-search-up    # Up
    bindkey '\e[B' history-substring-search-down  # Down
    bindkey '\ek'  history-substring-search-up    # Alt+k
    bindkey '\ej'  history-substring-search-down  # Alt+j
fi

# zsh-autopair (git clone, after syntax-highlighting)
_plugins_data="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
if [[ -f "${_plugins_data}/zsh-autopair/zsh-autopair.plugin.zsh" ]]; then
    source "${_plugins_data}/zsh-autopair/zsh-autopair.plugin.zsh"
fi
unset _plugins_data

# ── Custom widgets (register after plugins) ──────────────────
# Alt+s: toggle `sudo ` prefix
sudo-command-line() {
    if [[ -z $BUFFER ]]; then
        zle -M "buffer is empty"
        return
    fi
    if [[ $BUFFER == "sudo "* ]]; then
        BUFFER="${BUFFER#sudo }"
        (( CURSOR <= 5 )) && CURSOR=0 || (( CURSOR -= 5 ))
    else
        BUFFER="sudo $BUFFER"
        (( CURSOR += 5 ))
    fi
    zle redisplay
}
zle -N sudo-command-line
bindkey '\es' sudo-command-line

# Alt+e: edit the current command line in $EDITOR
edit-command-in-editor() {
    local tmpfile code
    tmpfile="$(mktemp /tmp/zsh-command.XXXXXX)"
    print -r -- "$BUFFER" > "$tmpfile"
    "$EDITOR" "$tmpfile"
    code=$?
    if [[ $code -eq 0 && -s $tmpfile ]]; then
        BUFFER="$(<"$tmpfile")"
        CURSOR=${#BUFFER}
        zle redisplay
    else
        zle -M "editor exited with code $code — buffer kept"
    fi
    rm -f "$tmpfile"
}
zle -N edit-command-in-editor
bindkey '\ee' edit-command-in-editor

# ── zoxide (replaces OMZ `z`) ────────────────────────────────
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd z)"

# ── colored man pages ────────────────────────────────────────
# Dracula palette
# (Alacritty's Dracula config redefines ANSI 16: blue=#bd93f9, cyan=#8be9fd, …)
export GROFF_NO_SGR=1
export LESS_TERMCAP_md=$'\e[1;34m'    # bold headings  → purple
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_us=$'\e[0;36m'    # underline      → cyan
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_so=$'\e[0;30;46m' # search hit     → dark text on cyan bg
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_mb=$'\e[1;31m'    # blink          → red
export LESS_TERMCAP_mr=$'\e[0;31m'    # reverse        → red

# ── Starship prompt ──────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ── bgnotify: desktop notification for long-running commands ─
BGNOTIFY_THRESHOLD=5      # seconds
BGNOTIFY_ICON=terminal

bgnotify_preexec() {
    bgnotify_cmd="$1"
    bgnotify_started=$SECONDS
}

bgnotify_precmd() {
    local cmd cwd
    cmd="${bgnotify_cmd:-}"
    [[ -z $cmd ]] && return

    if (( SECONDS - bgnotify_started >= BGNOTIFY_THRESHOLD )); then
        local cwd="${PWD##*/}"
        command -v notify-send &>/dev/null && \
            notify-send "Done: $cwd" "$cmd ($((SECONDS - bgnotify_started))s)" \
            --icon="$BGNOTIFY_ICON" --app-name="zsh"
        printf '\a'
    fi
    unset bgnotify_cmd
}

add-zsh-hook preexec bgnotify_preexec
add-zsh-hook precmd bgnotify_precmd

# ── Utilities ────────────────────────────────────────────────
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

extract() {
    [ -f "$1" ] || { echo "Usage: extract <archive>" >&2; return 1; }
    case "$1" in
        *.tar.bz2|*.tbz2)  tar xjf  "$1" ;;
        *.tar.gz|*.tgz)    tar xzf  "$1" ;;
        *.tar.xz)          tar xvJf "$1" ;;
        *.tar.zst|*.tzst)  tar --zstd -xf "$1" ;;
        *.tar)             tar xf   "$1" ;;
        *.bz2)             bunzip2  "$1" ;;
        *.gz)              gunzip   "$1" ;;
        *.xz)              unxz     "$1" ;;
        *.zip)             unzip    "$1" ;;
        *.7z)              7z x     "$1" ;;
        *.rar)             7z x     "$1" ;;
        *.iso)             7z x     "$1" ;;
        *) echo "Unsupported format: '$1'" >&2; return 1 ;;
    esac
}
