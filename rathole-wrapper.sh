#!/bin/sh
# Wrapper script for rathole with debug logging and diagnostics

echo "[*] Rathole wrapper starting..."
echo "    Config file: $1"

if [ ! -f "$1" ]; then
    echo "[!] ERROR: Config file not found: $1"
    exit 1
fi

echo "[*] Config file contents:"
cat "$1"

echo "[*] Checking rathole binary..."
ls -lh /usr/local/bin/rathole
file /usr/local/bin/rathole || echo "[!] 'file' command not available"

echo "[*] Checking libc dependencies..."
ldd /usr/local/bin/rathole 2>&1 || echo "[!] ldd check failed (expected on Alpine)"

echo "[*] Starting rathole with debug logging..."

export RUST_LOG=debug
exec /usr/local/bin/rathole "$1"
