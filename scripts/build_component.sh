#!/usr/bin/env bash
set -euo pipefail

readonly ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
readonly PROFILE=$ROOT/manifests/build-profile.json
readonly WORK=$ROOT/.work/component
readonly PAYLOAD=$WORK/payload

[[ -z $(git -C "$ROOT" status --porcelain=v1 --untracked-files=all) ]] || {
    echo 'error: source checkout is dirty' >&2
    exit 1
}

readarray -t profile < <(python3 - "$PROFILE" <<'PY'
import json, sys
p=json.load(open(sys.argv[1]))
print(p["lock_sha256"])
print(p["jobs"])
for key in ("LLVM_SYS_211_PREFIX","LLVM_ZLUDA_PREBUILT","CARGO_BUILD_JOBS","MAKEFLAGS","CARGO_INCREMENTAL"):
    print(p["environment"][key])
PY
)
readonly LOCK_SHA256=${profile[0]}
readonly JOBS=${profile[1]}
[[ $(sha256sum "$ROOT/Cargo.lock" | awk '{print $1}') == "$LOCK_SHA256" ]]

[[ $WORK == "$ROOT/.work/component" ]]
rm -rf "$WORK"
mkdir -p "$PAYLOAD/lib" "$WORK/evidence"

python3 "$ROOT/tests/test_component_artifact.py"
env \
    LLVM_SYS_211_PREFIX="${profile[2]}" \
    LLVM_ZLUDA_PREBUILT="${profile[3]}" \
    CARGO_BUILD_JOBS="${profile[4]}" \
    MAKEFLAGS="${profile[5]}" \
    CARGO_INCREMENTAL="${profile[6]}" \
    cargo build -p zluda --features nvidia --no-default-features --locked -j"$JOBS"

readonly LIB=$ROOT/target/debug/libnvcuda.so
[[ -f $LIB ]]
install -m 0755 "$LIB" "$PAYLOAD/lib/libnvcuda.so"
file "$PAYLOAD/lib/libnvcuda.so" | tee "$WORK/evidence/file.txt"
readelf -d "$PAYLOAD/lib/libnvcuda.so" | tee "$WORK/evidence/readelf-dynamic.txt"
ldd "$PAYLOAD/lib/libnvcuda.so" | tee "$WORK/evidence/ldd.txt"
nm -D --defined-only "$PAYLOAD/lib/libnvcuda.so" | tee "$WORK/evidence/exports.txt"
for symbol in cuInit cuLaunchKernel cuMemcpyDtoHAsync cuModuleGetGlobal_v2; do
    grep -Eq " [A-Z] ${symbol}$" "$WORK/evidence/exports.txt"
done

printf 'component_build=pass\npayload=%s\n' "$PAYLOAD"
