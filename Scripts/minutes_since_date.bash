#!/bin/bash -euo pipefail

if [ ${#} -eq 0 ]
then
# read from STDIN
DATE=$( cat )
else
DATE="${1}"
fi

SECONDS_FROM_EPOCH_TO_NOW=$( date "+%s" )
SECONDS_FROM_EPOCH_TO_DATE=$( date -j -f "%b %d %Y %T %Z" "${DATE}" "+%s" )

MINUTES_SINCE_DATE=$(( $(( ${SECONDS_FROM_EPOCH_TO_NOW}-${SECONDS_FROM_EPOCH_TO_DATE} ))/60 ))

echo "${MINUTES_SINCE_DATE}"
