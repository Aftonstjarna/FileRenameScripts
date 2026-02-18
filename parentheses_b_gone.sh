#!/bin/bash
# Recursively rename folders by removing parentheses and their contents + trailing spaces

find . -depth -type d | while IFS= read -r dir; do
    # Extract the base name (folder name) and parent directory
    base=$(basename "$dir")
    parent=$(dirname "$dir")

    # Remove parentheses and their contents, plus trailing spaces
    newbase=$(echo "$base" | sed -E 's/\s*\([^)]*\)//g' | sed 's/[[:space:]]*$//')

    # Only rename if the name actually changed
    if [[ "$base" != "$newbase" ]]; then
        newpath="$parent/$newbase"
        echo "Renaming: $dir → $newpath"
        mv -n "$dir" "$newpath"
    fi
done
