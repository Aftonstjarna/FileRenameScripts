#!/bin/bash
# Script to replace underscores (_) in filenames with colons (:)
# Works recursively from the current directory.

echo "🔍 Searching for files with underscores in their names..."

# Find all files (not directories) that contain underscores
find . -type f -name "*_*" | while read -r FILE; do
    DIR="$(dirname "$FILE")"
    NAME="$(basename "$FILE")"
    NEW_NAME="${NAME//_/:}"
    NEW_PATH="$DIR/$NEW_NAME"

    if [[ "$FILE" != "$NEW_PATH" ]]; then
        # Check if a file with the new name already exists
        if [[ -f "$NEW_PATH" ]]; then
            echo "⚠️ Skipping (target exists): $NEW_PATH"
        else
            mv "$FILE" "$NEW_PATH"
            echo "✅ Renamed: $FILE → $NEW_PATH"
        fi
    fi
done

echo "🎉 Done renaming files!"
