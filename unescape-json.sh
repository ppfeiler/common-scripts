#!/bin/bash

clipboard_content=$(xclip -o -selection clipboard)
decoded_clipboard_content=${clipboard_content//\\\"/\"}

if ! jq -e . >/dev/null 2>&1 <<<"$decoded_clipboard_content"; then
    echo "Failed to parse JSON"
    exit 1
fi

tmpfile=$(mktemp --suffix .json)
echo "$decoded_clipboard_content" | jq >> $tmpfile
kate $tmpfile
