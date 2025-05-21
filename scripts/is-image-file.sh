#!/usr/bin/env bash
set -e -o pipefail

CHECK_FILE=true
FILES=()

# Help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "Usage: $(basename "$0") [ARGUMENT] FILE..."
        echo "Checks if every given file is an image file."
        echo "ARGUMENT can be"
        echo "    --filename Only check the filename, do not check the file itself."
        echo "Exit codes:"
        echo "     0: Everything fine."
        echo "    14: File does not exist or is empty."
        echo "    20: File extension is not a known image extension."
        exit
    fi
done

# Check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--filename" ]]; then
        CHECK_FILE=false
    else
        FILES+=("$1")
    fi
    shift
done

for file in "${FILES[@]}"; do
    if [[ "${file,,}" != *.@(avif|heic|jpeg|jpg|png) ]]; then
        exit 20
    fi

    if [[ "$CHECK_FILE" == true ]]; then
        if [[ ! -s "$file" ]]; then
            exit 14
        fi
    fi
done
