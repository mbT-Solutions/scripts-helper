#!/usr/bin/env bash
set -e -o pipefail

DEPENDENCIES=(sha256sum mbuffer)
INPUT="-"
OUTPUT=""
SILENT=false

# Help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "Usage: $(basename "$0") [ARGUMENT]"
        echo "Saves piped data into a file and calculate the sha256sum for it."
        echo "The checksum is saved next to the file with \".sha256sum\" as suffix."
        echo "ARGUMENT can be"
        echo "    --input FILE The input file path. If not set, data is read from stdin."
        echo "    --output FILE The output file path."
        echo "    --silent Suppress all messages except errors."
        echo "Exit codes:"
        echo "     0: Everything fine."
        echo "     1: General error."
        echo "    10: Missing dependency."
        echo "    13: Unknown argument."
        echo "    14: Output directory does not exist."
        echo "    15: Missing argument."
        echo
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
while [[ -n "$1" ]]; do
    if [[ "$1" == "--input" ]]; then
        shift
        INPUT="$1"
    elif [[ "$1" == "--output" ]]; then
        shift
        OUTPUT="$1"
    elif [[ "$1" == "--silent" ]]; then
        SILENT=true
    else
        echo "Error: Unknown argument: \"$1\""
        exit 13
    fi
    shift
done

if [[ -z "$OUTPUT" ]]; then
    echo "Error: Missing output file path." >&2
    exit 15
fi
if [[ ! -d "$(dirname "${OUTPUT}")" ]]; then
    echo "Error: Output directory does not exist: \"$(dirname "${OUTPUT}")\"" >&2
    exit 14
fi

if [[ "$INPUT" != "-" ]]; then
        if [[ ! -f "$INPUT" ]]; then
        echo "Error: Input file does not exist: \"$INPUT\"" >&2
        exit 14
    fi
elif [[ -t 0 ]]; then
    echo "Error: No data piped to the script." >&2
    exit 1
fi

ADDIONAL_ARGUMENTS=()
if [[ "$SILENT" == true ]]; then
    ADDIONAL_ARGUMENTS+=(-q)
fi

mbuffer -e -f -i "$INPUT" -m 32M -o "${OUTPUT}" -o - "${ADDIONAL_ARGUMENTS[@]}" \
    | sha256sum \
    | sed "s|-$|$(basename "${OUTPUT}")|" \
    > "${OUTPUT}.sha256sum"
