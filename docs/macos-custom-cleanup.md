# Custom macOS cleanup

`scripts/macos/cleanup-macos.sh` is the shared home for custom cleanup rules
that Mole and general macOS maintenance do not cover. Keep each cleanup area in
focused functions with narrowly bounded roots.

The current Xcode rules remove two kinds of stale data:

- `.xcarchive` bundles below `~/Library/Developer/Xcode/Archives` whose macOS
  creation time is more than 14 days old;
- immediate child directories below
  `~/Library/Developer/Xcode/iOS DeviceSupport` whose access time is more than
  14 days old.

The access-time rule intentionally uses the filesystem atime rather than the
directory modification time: Xcode may read an installed support image without
changing its contents. This assumes the user's data volume continues to track
access times. Revisit the rule if that volume is mounted with `noatime` or Xcode
changes where it records device-support usage.

Install or refresh the user LaunchAgent with:

```bash
scripts/macos/install-macos-cleanup.sh
```

The installer copies the executable to `~/.local/bin/cleanup-macos` and loads
`com.karmenzind.macos-cleanup` in the current GUI user domain. It runs every
259,200 seconds (three days). A `StartInterval` firing that occurs while the Mac
is asleep is missed and is not replayed after waking. Output is appended to
`~/Library/Logs/com.karmenzind.macos-cleanup.log`.

Preview the current candidates without deleting anything:

```bash
~/.local/bin/cleanup-macos --dry-run
```

For isolated tests, `XCODE_ARCHIVES_ROOT` and `XCODE_DEVICE_SUPPORT_ROOT` may
override the two roots. `--retention-days` may override the retention period.
