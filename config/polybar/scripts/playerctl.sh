#!/bin/sh

# Define your Icons with Polybar colors
VLC_ICON="%{F#FF7F00}󰕼 %{F-}"
FIREFOX_ICON="%{F#FF0000}󰈹 %{F-}"
CHROME_ICON="%{F#FFFF00} %{F-}"
EDGE_ICON="%{F#00FFFF} %{F-}"
SPOTIFY_ICON="%{F#1DB954} %{F-}"
MUSIC_ICON="%{F#FF00FF}󰌳 %{F-}"

# File to store the current player
CURRENT_PLAYER_FILE="/tmp/current_player"

# Function to get player info
get_player_info() {
    PLAYER=$1
    ARTIST=$(playerctl -p "$PLAYER" metadata artist)
    TITLE=$(playerctl -p "$PLAYER" metadata title)

    # If either artist or title length is > 20, then cut and add ellipsis
    if [ "${#ARTIST}" -ge 21 ]; then
        ARTIST="$(printf '%s' "$ARTIST" | cut -c 1-20)..."
    fi

    if [ "${#TITLE}" -ge 21 ]; then
        TITLE="$(printf '%s' "$TITLE" | cut -c 1-30)..."
    fi

    case "$PLAYER" in
        "chromium")
            echo "$CHROME_ICON $TITLE - $ARTIST"
            ;;
        "edge")
            echo "$EDGE_ICON $TITLE - $ARTIST"
            ;;
        "vlc")
            echo "$VLC_ICON $TITLE - $ARTIST"
            ;;
        "spotify")
            echo "$SPOTIFY_ICON $TITLE - $ARTIST"
            ;;
        "firefox")
            echo "$FIREFOX_ICON $TITLE - $ARTIST"
            ;;
        "mpv")
            echo "$MUSIC_ICON $TITLE - $ARTIST"
            ;;
        *)
            echo "$MUSIC_ICON $TITLE - $ARTIST"
            ;;
    esac
}

# Check players in order of priority
if [ "$(playerctl -p spotify status 2>/dev/null)" = "Playing" ]; then
    echo "spotify" >"$CURRENT_PLAYER_FILE"
    get_player_info "spotify"
elif [ "$(playerctl -p edge status 2>/dev/null)" = "Playing" ]; then
    echo "edge" >"$CURRENT_PLAYER_FILE"
    get_player_info "edge"
elif [ "$(playerctl -p firefox status 2>/dev/null)" = "Playing" ]; then
    echo "firefox" >"$CURRENT_PLAYER_FILE"
    get_player_info "firefox"
elif [ "$(playerctl -p mpv status 2>/dev/null)" = "Playing" ]; then
    echo "mpv" >"$CURRENT_PLAYER_FILE"
    get_player_info "mpv"
elif [ "$(playerctl -p vlc status 2>/dev/null)" = "Playing" ]; then
    echo "vlc" >"$CURRENT_PLAYER_FILE"
    get_player_info "vlc"
elif [ "$(playerctl -p chromium status 2>/dev/null)" = "Playing" ]; then
    echo "chromium" >"$CURRENT_PLAYER_FILE"
    get_player_info "chromium"
else
    echo "%{F#FFAA33}󰝛 %{F-}Player is not running"
fi

# Handle click event to pause the current player
if [ "$1" = "pause" ]; then
    if [ -f "$CURRENT_PLAYER_FILE" ]; then
        CURRENT_PLAYER=$(cat "$CURRENT_PLAYER_FILE")
        playerctl -p "$CURRENT_PLAYER" play-pause
    fi
fi
