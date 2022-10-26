#!/usr/bin/env bash

## Applets : Quick Links

# Import Current Theme
source "$HOME"/.config/rofi/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Quick Links'
mesg="Using 'Microsoft Edge' as web browser"

if [[ ( "$theme" == *'styles'* ) ]]; then
	list_col='1'
	list_row='6'
	efonts="JetBrains Mono Nerd Font 10"
fi

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1=" Facebook"
	option_2=" Gmail"
	option_3=" Youtube"
	option_4=" Github"
	option_5=" QLDT PTIT"
	option_6=" Zalo"
else
	option_1=""
	option_2=""
	option_3=""
	option_4=""
	option_5=""
	option_6=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-theme-str "element-text {font: \"$efonts\";}" \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		microsoft-edge-stable 'https://www.facebook.com/'
	elif [[ "$1" == '--opt2' ]]; then
		microsoft-edge-stable 'https://mail.google.com/'
	elif [[ "$1" == '--opt3' ]]; then
		microsoft-edge-stable 'https://www.youtube.com/'
	elif [[ "$1" == '--opt4' ]]; then
		microsoft-edge-stable 'https://www.github.com/'
	elif [[ "$1" == '--opt5' ]]; then
		microsoft-edge-stable 'https://qldt.ptit.edu.vn/'
	elif [[ "$1" == '--opt6' ]]; then
		google-chrome-stable 'https://chat.zalo.me/'
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac
