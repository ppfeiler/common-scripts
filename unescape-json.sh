#!/bin/bash

detect_display_server() {
    if echo "$XDG_SESSION_TYPE" | grep -iq "wayland"; then
        echo "wayland"
    elif echo "$XDG_SESSION_TYPE" | grep -iq "x11"; then
        echo "x11"
    else
        echo "unknown"
    fi
}

detect_json_parser() {
    if command -v gojq >/dev/null; then
        echo "gojq"
    elif command -v jq >/dev/null; then
        echo "jq"
    else
        echo "none"
    fi
}

display_server=$(detect_display_server)
case "$display_server" in
    wayland)
        echo "Wayland detected"
        clipboard_command="wl-paste"
        ;;
    x11)
        echo "x11 detected"
        clipboard_command="xclip -o -selection clipboard"
        ;;
    *)
        echo "Unsupported display server or unable to detect. Exiting..."
        exit 1
        ;;
esac

json_parser=$(detect_json_parser)
if [ "$json_parser" = "none" ]; then
    echo "No JSON parser (jq or gojq) found. Exiting..."
    exit 1
fi

clipboard_content=$($clipboard_command)
decoded_clipboard_content=${clipboard_content//\\\"/\"}

if ! $json_parser -e . >/dev/null 2>&1 <<<"$decoded_clipboard_content"; then
    echo "Failed to parse JSON"
    exit 1
fi

tmpfile=$(mktemp --suffix .json)
echo "$decoded_clipboard_content" | $json_parser >> $tmpfile
kate $tmpfile
