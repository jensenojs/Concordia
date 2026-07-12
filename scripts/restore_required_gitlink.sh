#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
    printf 'usage: %s PATH URL COMMIT SPARSE_PATH...\n' "$0" >&2
    exit 2
fi

readonly ROOT=$(git rev-parse --show-toplevel)
readonly RELATIVE=$1
readonly URL=$2
readonly COMMIT=$3
shift 3
readonly DEST=$ROOT/$RELATIVE
readonly INDEX_COMMIT=$(git -C "$ROOT" ls-files -s "$RELATIVE" | awk '{print $2}')
[[ $INDEX_COMMIT == "$COMMIT" ]] || {
    echo "error: gitlink commit mismatch for $RELATIVE" >&2
    exit 1
}

if [[ -d $DEST ]]; then
    [[ -z $(find "$DEST" -mindepth 1 -maxdepth 1 -print -quit) ]] || {
        echo "error: gitlink destination is not empty: $DEST" >&2
        exit 1
    }
    rmdir "$DEST"
fi

git init "$DEST"
git -C "$DEST" remote add origin "$URL"
git -C "$DEST" sparse-checkout init --cone
git -C "$DEST" sparse-checkout set "$@"
git -C "$DEST" -c protocol.version=2 fetch --depth=1 --filter=blob:none origin "$COMMIT"
git -C "$DEST" checkout --detach FETCH_HEAD
[[ $(git -C "$DEST" rev-parse HEAD) == "$COMMIT" ]]

printf 'gitlink_restore=pass\npath=%s\ncommit=%s\nsparse_paths=%s\n' \
    "$RELATIVE" "$COMMIT" "$*"
