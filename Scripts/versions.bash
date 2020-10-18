#!/bin/bash -euo pipefail

# When we increment TW_BUNDLE_SHORT_VERSION_STRING
# also update TW_BUNDLE_SHORT_VERSION_DATE to the current date/time
# we don't have to be very exact, but it should be updated at least
# once every 18 months because iTunes requires that a CFBundleVersion
# be at most 18 characters long, and DECIMALIZED_GIT_HASH will be
# at most 10 characters long. Thus, MINUTES_SINCE_DATE needs to be
# at most 7 characters long so we can use the format:
# ${MINUTES_SINCE_DATE}.${DECIMALIZED_GIT_HASH}
#
TW_BUNDLE_SHORT_VERSION_DATE="October 1 2020 00:00:00 GMT"

BASH_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MINUTES_SINCE_DATE="$( cd "${BASH_SOURCE_DIR}" && ./minutes_since_date.bash "${TW_BUNDLE_SHORT_VERSION_DATE}" )"

# decimalized git hash is guaranteed to be 10 characters or fewer because
# the biggest short=7 git hash we can get is FFFFFFF and
# $ ./decimalize_git_hash.bash FFFFFFF | wc -c
# > 10
DECIMALIZED_GIT_HASH="$( cd "${BASH_SOURCE_DIR}"; ./decimalize_git_hash.bash $( git rev-parse --short=7 HEAD ) )"
echo "Decimalized: \"${DECIMALIZED_GIT_HASH}\""

TW_BUNDLE_VERSION="${MINUTES_SINCE_DATE}"."${DECIMALIZED_GIT_HASH}"
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleVersion" "${TW_BUNDLE_VERSION}"
