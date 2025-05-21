#!/usr/bin/env bash
set -e -o pipefail

DEPENDENCIES=(ffprobe sed sort)

# Help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "Usage: $(basename "$0") FILE"
        echo "Output a comma seperated list of audio languages in the given file."
        echo "Exit codes:"
        echo "     0: Everything fine."
        echo "     1: General error."
        echo "    10: Missing dependency."
        echo "    11: Already running."
        echo "    12: Must be run as root."
        echo "    13: Unknown argument."
        echo "    14: File does not exist or is empty."
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
if [[ "$#" -ne 1 ]]; then
    echo "Error: Exactly one file is required!" >&2
    exit 13
fi
FILE="$1"

if [[ ! -s "$FILE" ]]; then
    echo "Error: \"${FILE}\" does not exist or is empty!" >&2
    exit 14
fi

ffprobe -v error -show_entries stream_tags=language -select_streams a \
        -print_format default=noprint_wrappers=1:nokey=1 "$FILE" \
    | sed --expression "s|abk|ab|" --expression "s|aar|aa|" --expression "s|afr|af|" \
        --expression "s|aka|ak|" --expression "s|sqi|sq|" --expression "s|amh|am|" \
        --expression "s|ara|ar|" --expression "s|arg|an|" --expression "s|hye|hy|" \
        --expression "s|asm|as|" --expression "s|ava|av|" --expression "s|ave|ae|" \
        --expression "s|aym|ay|" --expression "s|aze|az|" --expression "s|bam|bm|" \
        --expression "s|bak|ba|" --expression "s|eus|eu|" --expression "s|bel|be|" \
        --expression "s|ben|bn|" --expression "s|bis|bi|" --expression "s|bos|bs|" \
        --expression "s|bre|br|" --expression "s|bul|bg|" --expression "s|mya|my|" \
        --expression "s|cat|ca|" --expression "s|cha|ch|" --expression "s|che|ce|" \
        --expression "s|nya|ny|" --expression "s|zho|zh|" --expression "s|chu|cu|" \
        --expression "s|chv|cv|" --expression "s|cor|kw|" --expression "s|cos|co|" \
        --expression "s|cre|cr|" --expression "s|hrv|hr|" --expression "s|ces|cs|" \
        --expression "s|dan|da|" --expression "s|div|dv|" --expression "s|nld|nl|" \
        --expression "s|dzo|dz|" --expression "s|eng|en|" --expression "s|epo|eo|" \
        --expression "s|est|et|" --expression "s|ewe|ee|" --expression "s|fao|fo|" \
        --expression "s|fij|fj|" --expression "s|fin|fi|" --expression "s|fra|fr|" \
        --expression "s|fry|fy|" --expression "s|ful|ff|" --expression "s|gla|gd|" \
        --expression "s|glg|gl|" --expression "s|lug|lg|" --expression "s|kat|ka|" \
        --expression "s|deu|de|" --expression "s|ell|el|" --expression "s|kal|kl|" \
        --expression "s|ger|de|" \
        --expression "s|grn|gn|" --expression "s|guj|gu|" --expression "s|hat|ht|" \
        --expression "s|hau|ha|" --expression "s|heb|he|" --expression "s|her|hz|" \
        --expression "s|hin|hi|" --expression "s|hmo|ho|" --expression "s|hun|hu|" \
        --expression "s|isl|is|" --expression "s|ido|io|" --expression "s|ibo|ig|" \
        --expression "s|ind|id|" --expression "s|ina|ia|" --expression "s|ile|ie|" \
        --expression "s|iku|iu|" --expression "s|ipk|ik|" --expression "s|gle|ga|" \
        --expression "s|ita|it|" --expression "s|jpn|ja|" --expression "s|jav|jv|" \
        --expression "s|kan|kn|" --expression "s|kau|kr|" --expression "s|kas|ks|" \
        --expression "s|kaz|kk|" --expression "s|khm|km|" --expression "s|kik|ki|" \
        --expression "s|kin|rw|" --expression "s|kir|ky|" --expression "s|kom|kv|" \
        --expression "s|kon|kg|" --expression "s|kor|ko|" --expression "s|kua|kj|" \
        --expression "s|kur|ku|" --expression "s|lao|lo|" --expression "s|lat|la|" \
        --expression "s|lav|lv|" --expression "s|lim|li|" --expression "s|lin|ln|" \
        --expression "s|lit|lt|" --expression "s|lub|lu|" --expression "s|ltz|lb|" \
        --expression "s|mkd|mk|" --expression "s|mlg|mg|" --expression "s|msa|ms|" \
        --expression "s|mal|ml|" --expression "s|mlt|mt|" --expression "s|glv|gv|" \
        --expression "s|mri|mi|" --expression "s|mar|mr|" --expression "s|mah|mh|" \
        --expression "s|mon|mn|" --expression "s|nau|na|" --expression "s|nav|nv|" \
        --expression "s|nde|nd|" --expression "s|nbl|nr|" --expression "s|ndo|ng|" \
        --expression "s|nep|ne|" --expression "s|nor|no|" --expression "s|nob|nb|" \
        --expression "s|nno|nn|" --expression "s|oci|oc|" --expression "s|oji|oj|" \
        --expression "s|ori|or|" --expression "s|orm|om|" --expression "s|oss|os|" \
        --expression "s|pli|pi|" --expression "s|pus|ps|" --expression "s|fas|fa|" \
        --expression "s|pol|pl|" --expression "s|por|pt|" --expression "s|pan|pa|" \
        --expression "s|que|qu|" --expression "s|ron|ro|" --expression "s|roh|rm|" \
        --expression "s|run|rn|" --expression "s|rus|ru|" --expression "s|sme|se|" \
        --expression "s|smo|sm|" --expression "s|sag|sg|" --expression "s|san|sa|" \
        --expression "s|srd|sc|" --expression "s|srp|sr|" --expression "s|sna|sn|" \
        --expression "s|snd|sd|" --expression "s|sin|si|" --expression "s|slk|sk|" \
        --expression "s|slv|sl|" --expression "s|som|so|" --expression "s|sot|st|" \
        --expression "s|spa|es|" --expression "s|sun|su|" --expression "s|swa|sw|" \
        --expression "s|ssw|ss|" --expression "s|swe|sv|" --expression "s|tgl|tl|" \
        --expression "s|tah|ty|" --expression "s|tgk|tg|" --expression "s|tam|ta|" \
        --expression "s|tat|tt|" --expression "s|tel|te|" --expression "s|tha|th|" \
        --expression "s|bod|bo|" --expression "s|tir|ti|" --expression "s|ton|to|" \
        --expression "s|tso|ts|" --expression "s|tsn|tn|" --expression "s|tur|tr|" \
        --expression "s|tuk|tk|" --expression "s|twi|tw|" --expression "s|uig|ug|" \
        --expression "s|ukr|uk|" --expression "s|urd|ur|" --expression "s|uzb|uz|" \
        --expression "s|ven|ve|" --expression "s|vie|vi|" --expression "s|vol|vo|" \
        --expression "s|wln|wa|" --expression "s|cym|cy|" --expression "s|wol|wo|" \
        --expression "s|xho|xh|" --expression "s|iii|ii|" --expression "s|yid|yi|" \
        --expression "s|yor|yo|" --expression "s|zha|za|" --expression "s|zul|zu|" \
    | sort --unique \
    | sed --null-data "s|\n\(.\)|,\1|g"
