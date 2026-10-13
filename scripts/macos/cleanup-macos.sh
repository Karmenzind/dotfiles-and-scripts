#!/usr/bin/env bash

set -euo pipefail

readonly DEFAULT_RETENTION_DAYS=14
readonly XCODE_ARCHIVES_DIR="${XCODE_ARCHIVES_ROOT:-$HOME/Library/Developer/Xcode/Archives}"
readonly XCODE_DEVICE_SUPPORT_DIR="${XCODE_DEVICE_SUPPORT_ROOT:-$HOME/Library/Developer/Xcode/iOS DeviceSupport}"
readonly LOG_FILE="${MACOS_CLEANUP_LOG_FILE:-$HOME/Library/Logs/com.karmenzind.macos-cleanup.log}"

retention_days=$DEFAULT_RETENTION_DAYS
dry_run=false
log_enabled=true

usage() {
	cat <<'EOF'
Usage: cleanup-macos [--dry-run] [--retention-days DAYS] [--no-log]

Run custom macOS cleanup rules that are not covered by Mole or general macOS
maintenance. The current Xcode rules remove archives created before the
retention window and iOS DeviceSupport directories that have not been accessed
during that window. The default retention period is 14 days.
EOF
}

while (($#)); do
	case $1 in
		--dry-run)
			dry_run=true
			;;
		--retention-days)
			if (($# < 2)); then
				echo "Missing value for --retention-days" >&2
				exit 2
			fi
			retention_days=$2
			shift
			;;
		--no-log)
			log_enabled=false
			;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage >&2
			exit 2
			;;
	esac
	shift
done

if [[ $OSTYPE != darwin* ]]; then
	echo "This cleanup is supported only on macOS." >&2
	exit 1
fi

if [[ ! $retention_days =~ ^[0-9]+$ ]] || ((retention_days < 1)); then
	echo "Retention days must be a positive integer." >&2
	exit 2
fi

if $log_enabled; then
	mkdir -p -- "$(dirname "$LOG_FILE")"
	exec > >(tee -a "$LOG_FILE") 2>&1
fi

readonly cutoff_epoch=$(($(date +%s) - retention_days * 86400))
removed_count=0
failed_count=0

log() {
	printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

remove_candidate() {
	local kind=$1
	local path=$2

	if $dry_run; then
		log "Would remove $kind: $path"
		return
	fi

	if rm -rf -- "$path"; then
		log "Removed $kind: $path"
		removed_count=$((removed_count + 1))
	else
		log "Failed to remove $kind: $path"
		failed_count=$((failed_count + 1))
	fi
}

cleanup_xcode_archives() {
	local archive birth_epoch

	if [[ ! -d $XCODE_ARCHIVES_DIR ]]; then
		log "Archives directory does not exist; skipping: $XCODE_ARCHIVES_DIR"
		return
	fi

	while IFS= read -r -d '' archive; do
		birth_epoch=$(stat -f '%B' -- "$archive" 2>/dev/null || printf '0')
		if [[ $birth_epoch =~ ^[0-9]+$ ]] && ((birth_epoch > 0 && birth_epoch < cutoff_epoch)); then
			remove_candidate "archive" "$archive"
		fi
	done < <(find "$XCODE_ARCHIVES_DIR" -mindepth 2 -maxdepth 2 -type d -name '*.xcarchive' -prune -print0)

	# Xcode groups archives in date directories. Remove a group after its last
	# archive has expired, but leave every non-empty directory untouched.
	if ! $dry_run; then
		find "$XCODE_ARCHIVES_DIR" -mindepth 1 -maxdepth 1 -type d -empty -exec rmdir -- {} \; 2>/dev/null || true
	fi
}

cleanup_xcode_device_support() {
	local device_dir access_epoch

	if [[ ! -d $XCODE_DEVICE_SUPPORT_DIR ]]; then
		log "DeviceSupport directory does not exist; skipping: $XCODE_DEVICE_SUPPORT_DIR"
		return
	fi

	while IFS= read -r -d '' device_dir; do
		access_epoch=$(stat -f '%a' -- "$device_dir" 2>/dev/null || printf '0')
		if [[ $access_epoch =~ ^[0-9]+$ ]] && ((access_epoch > 0 && access_epoch < cutoff_epoch)); then
			remove_candidate "DeviceSupport directory" "$device_dir"
		fi
	done < <(find "$XCODE_DEVICE_SUPPORT_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
}

run_cleanup_rules() {
	cleanup_xcode_archives
	cleanup_xcode_device_support
}

log "Starting custom macOS cleanup (retention: $retention_days days, dry run: $dry_run)"
run_cleanup_rules
log "Finished custom macOS cleanup (removed: $removed_count, failed: $failed_count)"

((failed_count == 0))
