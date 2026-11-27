#!/usr/bin/env bash
# Build the screenshot application in Kan-Linux(since v0.3.4)
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

BUILD_DIR=build_in_kanlinux
BUILD_TYPE=Release
RUN_TESTS=0
INSTALL=0
PREFIX=""

usage() {
    cat <<'EOF'
Usage: ./build.sh [options]

Options:
  --clean           Remove the build directory before configuring
  --debug           Configure a Debug build (default: Release)
  --test            Run ctest after building
  --install [DIR]   Install after building (default prefix: $HOME/.local)
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean) rm -rf "$BUILD_DIR" ;;
        --debug) BUILD_TYPE=Debug ;;
        --test) RUN_TESTS=1 ;;
        --install)
            INSTALL=1
            if [[ $# -gt 1 && "$2" != -* ]]; then
                PREFIX=$2
                shift
            fi
            ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
cmake --build "$BUILD_DIR"

if [[ $RUN_TESTS -eq 1 ]]; then
    ctest --test-dir "$BUILD_DIR" --output-on-failure --no-tests=error
fi

if [[ $INSTALL -eq 1 ]]; then
    PREFIX=${PREFIX:-$HOME/.local}
    cmake --install "$BUILD_DIR" --prefix "$PREFIX"
    echo "Installed to $PREFIX/bin/screenshot"
fi

echo "Build complete: $BUILD_DIR/screenshot"
