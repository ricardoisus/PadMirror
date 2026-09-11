#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
for tool in cmake ninja pkg-config; do
    command -v "$tool" >/dev/null || { echo 'Install build dependencies: brew install cmake ninja pkg-config gstreamer libplist openssl@3'; exit 1; }
done
git submodule update --init --recursive
python3 - <<'PY'
from pathlib import Path
import shutil
src = Path('ThirdParty/Popyachsa-AirPlay/third_party/uxplay')
dst = Path('.build/airplay-source')
shutil.copytree(src, dst, dirs_exist_ok=True, ignore=shutil.ignore_patterns('.git', 'build*'))
PY
git apply --directory=.build/airplay-source patches/0001-embedded-privacy-and-readiness.patch
cmake -S .build/airplay-source -B .build/airplay-engine -G Ninja \
    -DCMAKE_BUILD_TYPE=Release -DBUILD_CORE_DLL=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DGST_MACOS=OFF \
    -DNO_MARCH_NATIVE=ON -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-$(sw_vers -productVersion)}" \
    -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-headerpad_max_install_names
cmake --build .build/airplay-engine --target uxplay-core
printf 'Engine built at .build/airplay-engine/uxplay-core.dylib\n'
