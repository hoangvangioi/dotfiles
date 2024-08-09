#!/bin/sh

# Icon definitions
TRASH_ICON=""
CLEAN_ICON="󰃢"

# Color definitions
GREEN="%{F#00FF00}"
RED="%{F#ff5770}"
ORANGE="%{F#FF8B42}"
CYAN="%{F#77f2f2}"
NC="%{F-}" # No Color

# Trash directory and size limits
TRASH_DIR="$HOME/.local/share/Trash/files"
INFO_DIR="$HOME/.local/share/Trash/info"
ALERT_SIZE=1073741824  # 1 GB in bytes
LIMIT_TRASH_SIZE=2147483648  # 2 GB in bytes

# Function to get trash info
get_trash_info() {
    du_output=$(du -s "$TRASH_DIR") || {
        echo "Failed to get trash info"
        exit 1
    }
    size=$(echo "$du_output" | awk '{print $1}')
    trash_count=$(find "$TRASH_DIR" -type f | wc -l)

    # Convert size from KB to bytes
    size_bytes=$((size * 1024))
    human_readable_size=$(du -sh "$TRASH_DIR" | awk '{print $1}')

    # Output the information
    echo "$trash_count $human_readable_size $size_bytes"
}

# Function to display trash status
display_trash_status() {
    trash_count=$1
    size=$2
    size_bytes=$3

    if [ "$size_bytes" -gt "$ALERT_SIZE" ]; then
        echo "${RED}${TRASH_ICON}${NC} ${CYAN}${size}${NC}"
    elif [ "$trash_count" -gt 0 ]; then
        echo "${ORANGE}${TRASH_ICON}${NC} ${CYAN}${size}${NC}"
    else
        echo "${GREEN}${TRASH_ICON} ${NC}0"
    fi
}

# Function to clean trash if needed
clean_trash_if_needed() {
    trash_size=$(du -s "$TRASH_DIR" | awk '{print $1}')
    trash_size_bytes=$((trash_size * 1024))

    if [ "$trash_size_bytes" -gt "$LIMIT_TRASH_SIZE" ]; then
        rm -rf "${TRASH_DIR:?}/"*
    fi
}

# Function to clean trash
clean_trash() {
    echo "${GREEN}${CLEAN_ICON} ...${NC}"
    rm -rf "${TRASH_DIR:?}/"*
    rm -rf "${INFO_DIR:?}/"*
    rm -rf "${TRASH_DIR:?}/".*
    rm -rf "${INFO_DIR:?}/".*
    mkdir -p "$TRASH_DIR"
    mkdir -p "$INFO_DIR"
    echo "${GREEN}Trash cleaned.${NC}"
}

# Main function
main() {
    case "$1" in
    --clean)
        clean_trash
        ;;
    *)
        if [ ! -d "$TRASH_DIR" ] || [ ! -d "$INFO_DIR" ]; then
            echo "${RED}Error: Trash directories do not exist.${NC}"
            exit 1
        fi

        # Capture the output of get_trash_info into variables
        trash_info=$(get_trash_info)
        trash_count=$(echo "$trash_info" | awk '{print $1}')
        size=$(echo "$trash_info" | awk '{print $2}')
        size_bytes=$(echo "$trash_info" | awk '{print $3}')

        display_trash_status "$trash_count" "$size" "$size_bytes"
        clean_trash_if_needed
        ;;
    esac
}

main "$@"
