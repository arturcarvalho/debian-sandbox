#!/bin/bash
# Reinstall the zjstatus plugin used by layouts/main.kdl.
# Run this if the tab/status bar disappears (missing zjstatus.wasm).
set -euo pipefail

VERSION="v0.23.0"
DEST="$HOME/.config/zellij/plugins/zjstatus.wasm"
URL="https://github.com/dj95/zjstatus/releases/download/${VERSION}/zjstatus.wasm"

mkdir -p "$(dirname "$DEST")"
echo "Downloading zjstatus ${VERSION}..."
curl -fL --retry 2 "$URL" -o "$DEST"

# Sanity check: WASM files start with the magic bytes "\0asm".
if [ "$(od -An -tx1 -N4 "$DEST" | tr -d ' ')" != "0061736d" ]; then
    echo "Error: downloaded file is not a valid WASM binary" >&2
    rm -f "$DEST"
    exit 1
fi

echo "Installed $DEST"
echo "Re-attach or start a new zellij session for the bar to reload."
