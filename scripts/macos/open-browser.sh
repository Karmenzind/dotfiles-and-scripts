#!/usr/bin/env bash

# Browser preference shared by command-line tools and editor previews on macOS.
set -euo pipefail

if [[ $OSTYPE != darwin* ]]; then
    echo "This browser launcher is supported only on macOS." >&2
    exit 1
fi
if (($# == 0)); then
    echo "Usage: open-browser URL [URL ...]" >&2
    exit 2
fi

# Bundle identifiers also find apps outside /Applications. Try the next browser
# only when LaunchServices cannot open the requested URLs with this one.
for browser in com.google.Chrome com.apple.Safari org.chromium.Chromium org.mozilla.firefox; do
    if /usr/bin/open -b "$browser" -- "$@" 2>/dev/null; then
        exit 0
    fi
done
echo "Cannot open a browser (tried Chrome, Safari, Chromium, Firefox)." >&2
exit 1
