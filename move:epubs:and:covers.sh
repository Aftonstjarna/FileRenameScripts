#!/bin/bash
# Script to move EPUBs and their covers to the root directory (skipping existing files)
# and remove empty directories afterward.

ROOT_DIR="$(pwd)"

echo "📚 Scanning for EPUBs in subdirectories..."
echo

# Find all .epub files in subdirectories
find . -type f -name "*.epub" | while read -r EPUB; do
    DIR="$(dirname "$EPUB")"
    BASENAME="$(basename "$EPUB" .epub)"
    COVER="$DIR/cover.jpg"

    NEW_EPUB_PATH="$ROOT_DIR/${BASENAME}.epub"
    NEW_COVER_PATH="$ROOT_DIR/${BASENAME}.jpg"

    echo "Processing: $EPUB"

    # Move cover if exists
    if [[ -f "$COVER" ]]; then
        if [[ -f "$NEW_COVER_PATH" ]]; then
            echo "  ⚠️ Skipping cover (already exists): $NEW_COVER_PATH"
        else
            mv "$COVER" "$NEW_COVER_PATH"
            echo "  ✅ Moved cover → $NEW_COVER_PATH"
        fi
    else
        echo "  ⚠️ No cover found in: $DIR"
    fi

    # Move EPUB
    if [[ -f "$NEW_EPUB_PATH" ]]; then
        echo "  ⚠️ Skipping EPUB (already exists): $NEW_EPUB_PATH"
    else
        mv "$EPUB" "$NEW_EPUB_PATH"
        echo "  ✅ Moved EPUB → $NEW_EPUB_PATH"
    fi

    echo
done

# Remove empty directories
echo "🧹 Cleaning up empty directories..."
find . -type d -empty -not -path "." -delete
echo "✅ Cleanup complete."

echo
echo "🎉 Done moving EPUBs and covers!"
