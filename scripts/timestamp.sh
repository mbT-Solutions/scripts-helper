#!/usr/bin/env bash
set -e -o pipefail

TIMESTAMP=""
DEPENDENCIES=(date)
INCLUDE_DATE=true
PRECISION=milliseconds
REPLACE_WHITESPACE=false

# Help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "Usage: $(basename "$0") [ARGUMENT...]"
        echo "Output a formatted timestamp."
        echo "ARGUMENT can be:"
        echo "    --precision days|hours|minutes|seconds|milliseconds|microseconds|nanoseconds" \
            "The precision of the timestamp, default ${PRECISION}."
        echo "    --no-date Do not include the date in the timestamp."
        echo "    --no-whitespace Do not include whitespace in the timestamp."
        echo "    --timestamp STRING Use time described by STRING, not 'now'."
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
    if [[ "$1" == "--precision" ]]; then
        shift
        PRECISION="$1"
    elif [[ "$1" == "--no-date" ]]; then
        INCLUDE_DATE=false
    elif [[ "$1" == "--no-whitespace" ]]; then
        REPLACE_WHITESPACE=true
    elif [[ "$1" == "--timestamp" ]]; then
        shift
        TIMESTAMP="$1"
    else
        echo "Error: Unknown argument: \"$1\"" >&2
        exit 13
    fi
    shift
done

FORMAT_STRING=""
if [[ "$INCLUDE_DATE" == true ]]; then
    FORMAT_STRING+="%Y.%m.%d"
fi
case "$PRECISION" in
    days) if [[ "$INCLUDE_DATE" != true ]]; then echo "Error: Days precision requires date." >&2 \
        && exit 13; fi;;
    hours) FORMAT_STRING+=" %H";;
    minutes) FORMAT_STRING+=" %H.%M";;
    seconds) FORMAT_STRING+=" %H.%M.%S";;
    milliseconds) FORMAT_STRING+=" %H.%M.%S.%3N";;
    microseconds) FORMAT_STRING+=" %H.%M.%S.%6N";;
    nanoseconds) FORMAT_STRING+=" %H.%M.%S.%N";;
    *) echo "Error: Invalid precision: \"$PRECISION\"." >&2 && exit 13;;
esac

if [[ "$REPLACE_WHITESPACE" == true ]]; then
    FORMAT_STRING="${FORMAT_STRING//[[:blank:]]/-}"
fi

ADDITIONAL_ARGUMENTS=()
if [[ -n "$TIMESTAMP" ]]; then
    if ! date -d "$TIMESTAMP" "+%s" &>/dev/null; then
        if [[ "${TIMESTAMP:4:1}" == "." ]]; then
            YEAR="${TIMESTAMP:0:4}"
            MONTH="${TIMESTAMP:5:2}"
            DAY="${TIMESTAMP:8:2}"
            TIMESTAMP="${TIMESTAMP:11}"
        fi
        HOUR="${TIMESTAMP:0:2}"
        MIN="${TIMESTAMP:3:2}"
        SEC="${TIMESTAMP:6:2}"
        SEC_FRACTION="${TIMESTAMP:9}"
        TIMESTAMP="${YEAR:+${YEAR}-${MONTH}-${DAY}} "
        TIMESTAMP+="${HOUR:+${HOUR}${MIN:+:${MIN}}${SEC:+:${SEC}}${SEC_FRACTION:+.${SEC_FRACTION}}}"
    fi
    ADDITIONAL_ARGUMENTS+=(--date "$TIMESTAMP")
fi

date "${ADDITIONAL_ARGUMENTS[@]}" "+$FORMAT_STRING" 2>/dev/null || {
    if [[ -n "$TIMESTAMP" ]]; then
        echo "Error: Failed to parse timestamp." >&2
        exit 13
    fi
    echo "Error: Failed to generate timestamp." >&2
    exit 1
}
