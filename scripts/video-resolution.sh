#!/usr/bin/env bash
set -e -o pipefail

DEPENDENCIES=(ffprobe)
FILES=()

# Help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "Usage: $(basename "$0") [FILES]..."
        echo "Prints the video resolution of the input files."
        exit
    fi
done

# Check dependencies
for CMD in "${DEPENDENCIES[@]}"; do
    if [[ -z "$(which "$CMD")" ]]; then
        echo "Error: \"${CMD}\" is missing!" >&2
        exit 10
    fi
done

# Check arguments
FILES=("$@")

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Error: No input files specified." >&2
    exit 15
fi

for FILE in "${FILES[@]}"; do
    if [[ ! -s "$FILE" ]]; then
        echo "Error: \"${FILE}\" does not exist or is empty!" >&2
        exit 14
    fi

    FFPROBE_OUTPUT="$(ffprobe -v error -select_streams V:0 -show_entries \
    "stream=width,height" -print_format compact "$FILE")"

    VIDEO_WIDTH="$(sed --silent 's/^.*|width=\([^|]*\)|.*$/\1/p' <<< "$FFPROBE_OUTPUT")"
    VIDEO_HEIGHT="$(sed --silent 's/^.*|height=\([^|]*\)\(|.*\)\?$/\1/p' <<< "$FFPROBE_OUTPUT")"

    if [[ "$((VIDEO_WIDTH * 100 / VIDEO_HEIGHT))" -gt "$(( 1600 / 9 ))" ]]; then
        echo "$((VIDEO_WIDTH * 9 / 16 ))p"
    else
        echo "${VIDEO_HEIGHT}p"
    fi
done
