#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOOL_DIR="$ROOT_DIR/.pdfcrack"
TOOL="$TOOL_DIR/pdfcrack"
VERSION="0.21"
DOWNLOAD_URL="https://downloads.sourceforge.net/project/pdfcrack/pdfcrack/pdfcrack-${VERSION}/pdfcrack-${VERSION}.tar.gz"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -ne 1 ]]; then
    printf 'Usage: %s PDF_FILE\n' "$(basename "$0")"
    printf 'Searches 4- to 6-digit numeric passwords (0000-999999).\n'
    exit $([[ $# -eq 1 ]] && echo 0 || echo 2)
fi

PDF_FILE="$1"
if [[ ! -f "$PDF_FILE" && -f "$ROOT_DIR/$PDF_FILE" ]]; then
    PDF_FILE="$ROOT_DIR/$PDF_FILE"
fi
if [[ ! -f "$PDF_FILE" ]]; then
    printf 'PDF not found: %s\n' "$1" >&2
    exit 2
fi

if [[ ! -x "$TOOL" ]]; then
    command -v curl >/dev/null 2>&1 || { echo 'curl is required to build PDFCrack.' >&2; exit 1; }
    command -v make >/dev/null 2>&1 || { echo 'make is required to build PDFCrack.' >&2; exit 1; }
    command -v cc >/dev/null 2>&1 || { echo 'A C compiler is required to build PDFCrack.' >&2; exit 1; }

    build_dir="$(mktemp -d "$ROOT_DIR/.pdfcrack-build.XXXXXX")"
    trap 'rm -rf -- "$build_dir"' EXIT
    archive="$build_dir/pdfcrack.tar.gz"
    printf 'Downloading PDFCrack %s...\n' "$VERSION"
    curl -fsSL "$DOWNLOAD_URL" -o "$archive"
    tar -xzf "$archive" -C "$build_dir"
    cd "$build_dir/pdfcrack-$VERSION"
    make
    mkdir -p "$TOOL_DIR"
    cp -- pdfcrack "$TOOL"
    chmod 755 "$TOOL"
    printf 'Built and cached at %s\n' "$TOOL"
fi

exec "$TOOL" -f "$PDF_FILE" -c 0123456789 -n 4 -m 6
