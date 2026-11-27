#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

readonly DEFAULT_RETENTION_DAYS=14
readonly XCODE_ARCHIVES_DIR="${XCODE_ARCHIVES_ROOT:-$HOME/Library/Developer/Xcode/Archives}"
readonly XCODE_DEVICE_SUPPORT_DIR="${XCODE_DEVICE_SUPPORT_ROOT:-$HOME/Library/Developer/Xcode/iOS DeviceSupport}"
readonly ZAPPY_DIR="$HOME/Pictures/Zappy"
readonly LOG_FILE="${MACOS_CLEANUP_LOG_FILE:-$HOME/Library/Logs/com.karmenzind.macos-cleanup.log}"
retention_days=$DEFAULT_RETENTION_DAYS
dry_run=false
log_enabled=true

usage() {
	cat <<'EOF'
Usage: cleanup-macos [--dry-run] [--retention-days DAYS] [--no-log]

Xcode archives: creation time older than DAYS (default 14).
DeviceSupport: last access older than DAYS (default 14).
Zappy: regular files last modified more than 3 days ago.
Simulator runtimes: keep the newest version per platform/major, and remove
runtimes explicitly last used more than 30 days ago. Unknown usage is kept
unless superseded. Active Xcode/Simulator data is protected.
General caches remain managed separately by Mole.
EOF
}

while (($#)); do
	case $1 in
		--dry-run) dry_run=true ;;
		--retention-days)
			if (($# < 2)); then echo "Missing value for --retention-days" >&2; exit 2; fi
			retention_days=$2
			shift
			;;
		--no-log) log_enabled=false ;;
		-h | --help) usage; exit 0 ;;
		*) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
	esac
	shift
done
if [[ $OSTYPE != darwin* ]]; then echo "This cleanup is supported only on macOS." >&2; exit 1; fi
if [[ ! $retention_days =~ ^[0-9]+$ ]] || ((10#$retention_days < 1)); then
	echo "Retention days must be a positive integer." >&2
	exit 2
fi
retention_days=$((10#$retention_days))
if $log_enabled; then
	mkdir -p -- "$(dirname "$LOG_FILE")"
	exec > >(tee -a "$LOG_FILE") 2>&1
fi

# Locate the bundled planner even when this executable is installed as a link.
script_path=${BASH_SOURCE[0]}
while [[ -L $script_path ]]; do
	script_dir=$(cd -P -- "$(dirname -- "$script_path")" && pwd)
	script_path=$(readlink "$script_path")
	[[ $script_path == /* ]] || script_path="$script_dir/$script_path"
done
readonly script_dir=$(cd -P -- "$(dirname -- "$script_path")" && pwd)
readonly work_dir=$(mktemp -d "${TMPDIR:-/tmp}/macos-cleanup.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT
readonly cutoff_epoch=$(($(date +%s) - retention_days * 86400))
removed_count=0
failed_count=0
candidate_count=0
candidate_bytes=0
removed_bytes=0

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }
fail() { log "ERROR: $*"; failed_count=$((failed_count + 1)); }
human_bytes() { awk -v bytes="$1" 'BEGIN { printf "%.2f GiB (%s bytes)", bytes / 1073741824, bytes }'; }

free_bytes() {
	local output value
	if ! output=$(df -Pk "$HOME"); then return 1; fi
	value=$(printf '%s\n' "$output" | awk 'NR == 2 { printf "%.0f", $4 * 1024 }')
	[[ $value =~ ^[0-9]+$ ]] || return 1
	printf '%s' "$value"
}

# Check application/build/debug processes, not always-on CoreSimulator services.
# Unknown process state is an error and never authorizes Xcode deletion.
xcode_idle() {
	local processes
	if ! processes=$(ps -axo comm=); then
		fail "Cannot inspect development processes; skipping Xcode cleanup"
		return 1
	fi
	if printf '%s\n' "$processes" | grep -E '(^|/)(Xcode|Xcode-beta|Simulator|xcodebuild|xctest|xctrace|XCBBuildService|SWBBuildService|XCPreviewAgent|lldb-rpc-server)$' >/dev/null; then
		log "Development tools are active; deferring Xcode cleanup"
		return 1
	fi
}

measure_path() {
	local output kb
	if ! output=$(du -sk -- "$1"); then return 1; fi
	kb=${output%%$'\t'*}
	kb=${kb//[[:space:]]/}
	[[ $kb =~ ^[0-9]+$ ]] || return 1
	printf '%s' "$((kb * 1024))"
}

remove_candidate() {
	local kind=$1 path=$2 developer_data=$3 size
	# find never follows links; recheck the candidate before measuring/removal.
	if [[ -L $path || ! -e $path ]]; then fail "Candidate changed or disappeared: $path"; return; fi
	if ! size=$(measure_path "$path"); then fail "Cannot measure candidate: $path"; return; fi
	candidate_count=$((candidate_count + 1))
	candidate_bytes=$((candidate_bytes + size))
	log "Candidate $kind: $path; estimated allocated size: $(human_bytes "$size")"
	if $dry_run; then log "Would remove $kind: $path"; return; fi
	if $developer_data && ! xcode_idle; then return; fi
	if rm -rf -- "$path"; then
		log "Removed $kind: $path"
		removed_count=$((removed_count + 1))
		removed_bytes=$((removed_bytes + size))
	else
		fail "Failed to remove $kind: $path"
	fi
}

cleanup_files() {
	local root=$1 kind=$2 stat_field=$3 cutoff=$4 developer_data=$5
	shift 5
	local path epoch
	if [[ -L $root ]]; then fail "Refusing symlink cleanup root: $root"; return; fi
	if [[ ! -e $root ]]; then log "Directory does not exist; skipping: $root"; return; fi
	if [[ ! -d $root ]]; then fail "Cleanup root is not a directory: $root"; return; fi
	# Collect the entire scan first: a failed find must not look like an empty root.
	if ! find "$root" "$@" -print0 > "$work_dir/files"; then
		fail "Cannot completely scan: $root"
		return
	fi
	while IFS= read -r -d '' path; do
		if ! epoch=$(stat -f "$stat_field" -- "$path"); then
			fail "Cannot read timestamp: $path"
			continue
		fi
		if [[ ! $epoch =~ ^[0-9]+$ ]] || ((epoch <= 0)); then
			fail "Invalid timestamp for: $path"
			continue
		fi
		if ((epoch < cutoff)); then remove_candidate "$kind" "$path" "$developer_data"; fi
	done < "$work_dir/files"
}

runtime_plan() {
	if ! xcrun simctl runtime list -j > "$work_dir/images.json"; then
		fail "Cannot list simulator runtime images"; return 1
	fi
	if ! xcrun simctl list devices -j > "$work_dir/devices.json"; then
		fail "Cannot inspect simulator device states"; return 1
	fi
	if ! osascript -l JavaScript "$script_dir/simulator-runtime-plan.js" \
		"$work_dir/images.json" "$work_dir/devices.json" "$(date +%s)" > "$work_dir/plan"; then
		fail "Cannot validate simulator runtime metadata"; return 1
	fi
}

cleanup_simulator_runtimes() {
	local action id size reason current
	if ! command -v xcrun >/dev/null 2>&1; then log "xcrun is unavailable; skipping simulator runtimes"; return; fi
	if ! runtime_plan; then return; fi
	# TSV contains validated identifiers, numbers and fixed reason codes only.
	cp "$work_dir/plan" "$work_dir/initial-plan"
	while IFS=$'\t' read -r action id size reason; do
		[[ -n $action ]] || continue
		if [[ $action == keep ]]; then log "Keep runtime $id: $reason"; continue; fi
		candidate_count=$((candidate_count + 1))
		candidate_bytes=$((candidate_bytes + size))
		log "Candidate runtime $id: $reason; simctl image size: $(human_bytes "$size")"
		if $dry_run; then log "Would remove runtime: $id"; continue; fi
		if ! xcode_idle; then return; fi
		# simctl deletion can forcibly shut down devices, so re-plan immediately
		# before EACH removal and require the candidate still to be eligible.
		if ! runtime_plan; then return; fi
		current=$(awk -F '\t' -v id="$id" '$1 == "delete" && $2 == id { print $2 }' "$work_dir/plan")
		if [[ $current != "$id" ]]; then log "Runtime eligibility changed; keeping: $id"; continue; fi
		if xcrun simctl runtime delete "$id"; then
			# Confirm the manager no longer reports the image before counting it.
			if ! xcrun simctl runtime list -j > "$work_dir/verify.json"; then
				fail "Cannot verify deleted runtime: $id"; continue
			fi
			if ! osascript -l JavaScript "$script_dir/simulator-runtime-plan.js" \
				--verify-absent "$work_dir/verify.json" "$id"; then
				fail "Runtime deletion is incomplete or unverifiable: $id"; continue
			fi
			log "Removed runtime: $id"
			removed_count=$((removed_count + 1))
			removed_bytes=$((removed_bytes + size))
		else
			fail "Failed to delete runtime: $id"
		fi
	done < "$work_dir/initial-plan"
}

log "Starting custom macOS cleanup (Xcode retention: $retention_days days, dry run: $dry_run)"
free_before=""
if free_before=$(free_bytes); then log "Free space before: $(human_bytes "$free_before")"; else fail "Cannot read free space before cleanup"; fi
log "General caches are managed separately by Mole; no broad cache deletion is performed here"
# Dry-run still reports candidates while explaining that real deletion is deferred.
developer_idle=false
if xcode_idle; then developer_idle=true; fi
if $developer_idle || $dry_run; then
	cleanup_files "$XCODE_ARCHIVES_DIR" archive '%B' "$cutoff_epoch" true \
		-mindepth 2 -maxdepth 2 -type d -name '*.xcarchive' -prune
	cleanup_files "$XCODE_DEVICE_SUPPORT_DIR" "DeviceSupport directory" '%a' "$cutoff_epoch" true \
		-mindepth 1 -maxdepth 1 -type d
	cleanup_simulator_runtimes
fi
cleanup_files "$ZAPPY_DIR" "Zappy file" '%m' "$(($(date +%s) - 3 * 86400))" false -type f
free_after=""
if free_after=$(free_bytes); then
	log "Free space after: $(human_bytes "$free_after")"
	if [[ -n $free_before ]]; then log "Observed free-space change: $(human_bytes "$((free_after - free_before))")"; fi
else
	fail "Cannot read free space after cleanup"
fi
log "Finished custom macOS cleanup (candidates: $candidate_count, removed: $removed_count, failed: $failed_count)"
log "Candidate size estimate: $(human_bytes "$candidate_bytes"); removed size estimate: $(human_bytes "$removed_bytes")"
log "Size estimates are not guaranteed reclaimed space (APFS sharing, snapshots, and concurrent writes)"
((failed_count == 0))
