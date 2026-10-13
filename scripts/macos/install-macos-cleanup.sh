#!/usr/bin/env bash

set -euo pipefail

if [[ $OSTYPE != darwin* ]]; then
	echo "This installer is supported only on macOS." >&2
	exit 1
fi

readonly script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly executable_source="$script_dir/cleanup-macos.sh"
readonly executable_target="$HOME/.local/bin/cleanup-macos"
readonly label="com.karmenzind.macos-cleanup"
readonly plist_source="$script_dir/$label.plist"
readonly plist_target="$HOME/Library/LaunchAgents/$label.plist"
readonly launch_domain="gui/$(id -u)"
readonly legacy_label="com.karmenzind.xcode-cleanup"
readonly legacy_plist="$HOME/Library/LaunchAgents/$legacy_label.plist"
readonly legacy_executable="$HOME/.local/bin/cleanup-xcode"

mkdir -p -- "$(dirname "$executable_target")" "$(dirname "$plist_target")"
install -m 0755 "$executable_source" "$executable_target"
install -m 0644 "$plist_source" "$plist_target"

# Migrate installations made before this became the shared custom cleanup.
launchctl bootout "$launch_domain/$legacy_label" 2>/dev/null || true
rm -f -- "$legacy_plist" "$legacy_executable"

launchctl bootout "$launch_domain/$label" 2>/dev/null || true
launchctl bootstrap "$launch_domain" "$plist_target"
launchctl enable "$launch_domain/$label"

echo "Installed $executable_target"
echo "Loaded $label; it runs every 3 days."
echo "Preview manually with: $executable_target --dry-run"
