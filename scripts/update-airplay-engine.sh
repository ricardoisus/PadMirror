#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
revision="${1:-}"
[[ "$revision" =~ ^[0-9a-f]{40}$ ]] || { echo 'Usage: update-airplay-engine.sh <full-reviewed-upstream-commit>'; exit 2; }
upstream=ThirdParty/Popyachsa-AirPlay
[[ -z "$(git -C "$upstream" status --porcelain)" ]] || { echo 'Upstream has local changes; preserve them before updating.'; exit 1; }
git -C "$upstream" fetch origin "$revision"
git -C "$upstream" checkout --detach "$revision"
git -C "$upstream" submodule update --init --recursive
echo 'Review LICENSE/NOTICE, patch applicability and C ABI. Then build and physically test before committing the new gitlink.'
git diff --submodule=short -- "$upstream"
