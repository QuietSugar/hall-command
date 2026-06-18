#!/bin/bash

if [ "$(uname -s)" = "Darwin" ] && [ "$(uname -m)" = "x86_64" ]; then
    target="x86_64-apple-darwin"
elif [ "$(uname -s)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
    target="aarch64-apple-darwin"
elif [ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "x86_64" ]; then
    target="x86_64-unknown-linux-musl"
elif [ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "aarch64" ]; then
    target="aarch64-unknown-linux-musl"
elif [ "$(uname -s)" = "Linux" ] && ( uname -m | grep -q -e '^arm' ); then
    target="arm-unknown-linux-gnueabihf"
elif ( uname -s | grep -q -E -e '^(MINGW64_NT|MSYS_NT|CYGWIN_NT)' ) && [ "$(uname -m)" = "x86_64" ]; then
    target="x86_64-pc-windows-gnu"
elif ( uname -s | grep -q -E -e '^(MINGW32_NT|MSYS_NT|CYGWIN_NT)' ) && [ "$(uname -m)" = "i686" ]; then
    target="i686-pc-windows-gnu"
else
    echo "unknown OS or architecture"
    exit 1
fi
echo "$target"
