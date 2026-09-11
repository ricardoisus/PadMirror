#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ "$(uname -s)" == Darwin ]] || { echo 'macOS 14+ required'; exit 1; }
xcrun --find swift >/dev/null || { echo 'Install Xcode 16+ or Command Line Tools: xcode-select --install'; exit 1; }
xcrun swift --version
echo 'USB milestone: no Homebrew, Rust, CMake or GStreamer dependencies required.'
