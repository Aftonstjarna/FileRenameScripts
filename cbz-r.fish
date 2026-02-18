#!/usr/bin/env fish

# Directory to search (default: current directory)
set SEARCH_DIR (test -n "$argv[1]"; and echo $argv[1]; or echo ".")

# Regex pattern that marks the start of the "real" filename
set CONTENT_START '^(Vol\.|Ch\.|Chapter|Volume|Episode|Ep\.|[0-9])'

function strip_prefix
    set filename $argv[1]
    set newname $filename

    while true
        # Stop if the current name already starts with a content marker
        if echo $newname | grep -qiE $CONTENT_START
            break
        end

        set stripped (echo $newname | sed 's/^_*[^_]*_//')

        # Stop if nothing changed or result is empty
        if test "$stripped" = "$newname"; or test -z "$stripped"
            break
        end

        set newname $stripped
    end

    echo $newname
end

function extract_credits
    set filename $argv[1]
    set newname (strip_prefix $filename)

    if test "$newname" != "$filename"
        # Remove the newname suffix and trailing underscore to get the prefix
        set prefix (string replace -- "_$newname" "" $filename)
        set prefix (string trim --chars=_ $prefix)
        echo $prefix
    end
end

function add_credit
    set dir $argv[1]
    set credit $argv[2]
    set credits_file "$dir/credits.txt"

    if not test -f $credits_file; or not grep -qxF $credit $credits_file
        echo $credit >> $credits_file
        echo "      [credits.txt] Added: \"$credit\" in $dir"
    end
end

echo "Searching in: $SEARCH_DIR"
echo "Mode: DRY RUN"
echo "---"

find $SEARCH_DIR -depth -type f ! -name "credits.txt" | while read -l filepath
    set dir (dirname $filepath)
    set filename (basename $filepath)
    set newname (strip_prefix $filename)
    set credit (extract_credits $filename)

    if test "$newname" != "$filename"
        echo "  FROM: $filepath"
        echo "    TO: $dir/$newname"
        if test -n "$credit"
            echo "  CREDIT: \"$credit\""
        end
        echo ""
    end
end

echo "---"
echo "DRY RUN complete."
echo ""
read --prompt-str "Apply these changes? (y/N): " confirm

if string match -qir '^y$' $confirm
    echo ""
    echo "Applying changes..."
    echo "---"

    find $SEARCH_DIR -depth -type f ! -name "credits.txt" | while read -l filepath
        set dir (dirname $filepath)
        set filename (basename $filepath)
        set newname (strip_prefix $filename)
        set credit (extract_credits $filename)

        if test "$newname" != "$filename"
            mv $filepath $dir/$newname
            echo "  Renamed: $filename"
            echo "       To: $dir/$newname"

            if test -n "$credit"
                add_credit $dir $credit
            end
            echo ""
        end
    end

    echo "---"
    echo "Done!"
else
    echo "Aborted. No files were renamed."
end
