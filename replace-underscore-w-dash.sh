#!/bin/bash

# Directory to search (default: current directory)
SEARCH_DIR="${1:-.}"

fix_underscores() {
    local filename="$1"
    # Replace underscore touching a word (before or after) with " -"
    # "File_ 55" -> "File - 55"
    # "File _55" -> "File - 55"
    # "File_55"  -> "File - 55"
    local newname="$filename"
    # Underscore with optional spaces around it -> " - "
    newname=$(echo "$newname" | sed 's/ *_ */ - /g')
    # Clean up any double spaces
    newname=$(echo "$newname" | sed 's/  */ /g')
    # Trim leading/trailing spaces before extension
    newname=$(echo "$newname" | sed 's/^ //;s/ $//')
    echo "$newname"
}

echo "Searching in: $SEARCH_DIR"
echo "Mode: DRY RUN"
echo "---"

find "$SEARCH_DIR" -depth -type f | while IFS= read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")
    newname=$(fix_underscores "$filename")

    if [ "$newname" != "$filename" ]; then
        echo "  FROM: $filename"
        echo "    TO: $newname"
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

    find "$SEARCH_DIR" -depth -type f | while IFS= read -r filepath; do
        dir=$(dirname "$filepath")
        filename=$(basename "$filepath")
        newname=$(fix_underscores "$filename")

        if [ "$newname" != "$filename" ]; then
            mv "$filepath" "$dir/$newname"
            echo "  Renamed: $filename"
            echo "       To: $newname"
            echo ""
        fi
    done

    echo "---"
    echo "Done!"
else
    echo "Aborted. No files were renamed."
fi
