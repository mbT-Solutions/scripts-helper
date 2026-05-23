#!/usr/bin/env bash
set -e -o pipefail

# Help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "Usage: $(basename "$0") DURATION"
        echo "Converts a duration with a time unit to seconds."
        echo "Supported units: s (seconds), m (minutes), h (hours), d (days), w (weeks), M (months), Q (quarters), y (years)." \
            "Default unit is seconds if no unit is specified."
        echo "Calculations are based on the Gregorian year (365,2425 days)."
        exit
    fi
done

# Check arguments
if [[ "$#" -lt 1 ]]; then
    echo "Error: A duration argument is required." >&2
    exit 15
elif [[ "$#" -gt 1 ]]; then
    echo "Error: Only a single duration argument is allowed." >&2
    exit 13
fi
DURATION="$1"

SUFFIX="${DURATION##*[0-9]}"
DURATION="${DURATION%"$SUFFIX"}"
SUFFIX="${SUFFIX//[[:blank:]]/}"

if ! [[ "$DURATION" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid duration value: \"$DURATION\"." >&2
    exit 13
fi

case "$SUFFIX" in
    s|"") echo "$DURATION";;
    m) echo "$((DURATION * 60))";;
    h) echo "$((DURATION * 3600))";; # 60 * m
    d) echo "$((DURATION * 86400))";; # 24 * h
    w) echo "$((DURATION * 604800))";; # 7 * d
    M) echo "$((DURATION * 2629746))";; # y / 12
    Q) echo "$((DURATION * 7889238))";; # 3 * M
    y) echo "$((DURATION * 31556952))";; # 365.2425 * d
    *) echo "Error: Invalid duration suffix: \"$SUFFIX\"." >&2 && exit 13;;
esac
