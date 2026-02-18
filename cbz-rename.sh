#!/bin/bash

# Directory to search (default: current directory)
SEARCH_DIR="${1:-.}"

# Regex pattern that marks the start of the "real" filename
CONTENT_START='^(Vol\.|Ch\.|Chapter|Volume|Episode|Ep\.|[0-9])'

strip_prefix() {
    local filename="$1"
    local newname="$filename"
    while true; do
        # Stop if the current name already starts with a content marker
        if echo "$newname" | grep -qiE "$CONTENT_START"; then
            break
        fi
        stripped=$(echo "$newname" | sed 's/^_*[^_]*_//')
        # Stop if nothing changed or result is empty
        if [ "$stripped" = "$newname" ] || [ -z "$stripped" ]; then
            break
        fi
        newname="$stripped"
    done
    echo "$newname"
}

extract_credits() {
    local filename="$1"
    local newname
    newname=$(strip_prefix "$filename")
    if [ "$newname" != "$filename" ]; then
        local prefix="${filename%_$newname}"
        prefix="${prefix#_}"
        prefix="${prefix%_}"
        echo "$prefix"
    fi
}

add_credit() {
    local dir="$1"
    local credit="$2"
    local credits_file="$dir/credits.txt"

    if [ ! -f "$credits_file" ] || ! grep -qxF "$credit" "$credits_file"; then
        echo "$credit" >> "$credits_file"
        echo "      [credits.txt] Added: \"$credit\" in $dir"
    fi
}

echo "Searching in: $SEARCH_DIR"
echo "Mode: DRY RUN"
echo "---"

find "$SEARCH_DIR" -depth -type f ! -name "credits.txt" | while IFS= read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")
    newname=$(strip_prefix "$filename")
    credit=$(extract_credits "$filename")

    if [ "$newname" != "$filename" ]; then
        echo "  FROM: $filepath"
        echo "    TO: $dir/$newname"
        [ -n "$credit" ] && echo "  CREDIT: \"$credit\""
        echo ""
    fi
done

echo "---"
echo "DRY RUN complete."
echo ""
read -p "Apply these changes? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Applying changes..."
    echo "---"

    find "$SEARCH_DIR" -depth -type f ! -name "credits.txt" | while IFS= read -r filepath; do
        dir=$(dirname "$filepath")
        filename=$(basename "$filepath")
        newname=$(strip_prefix "$filename")
        credit=$(extract_credits "$filename")

        if [ "$newname" != "$filename" ]; then
            mv "$filepath" "$dir/$newname"
            echo "  Renamed: $filename"
            echo "       To: $dir/$newname"

            if [ -n "$credit" ]; then
                add_credit "$dir" "$credit"
            fi
            echo ""
        fi
    done

    echo "---"
    echo "Done!"
else
    echo "Aborted. No files were renamed."
fi
