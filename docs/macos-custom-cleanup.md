# Custom macOS cleanup

`scripts/macos/cleanup-macos.sh` is the shared home for custom cleanup rules
that need a custom retention policy. Keep each cleanup area in focused functions
with narrowly bounded roots; leave general cache cleanup to Mole.

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

The Zappy rule recursively removes regular files below `~/Pictures/Zappy`
whose modification time is more than 72 hours old. It keeps directories and
does not follow symbolic links. Its fixed three-day retention is independent
of `--retention-days`, which only controls the Xcode rules. Missing roots are
skipped, and `--dry-run` previews all rules without deleting anything.

Simulator runtime images have a separate policy, implemented with the bundled
`simulator-runtime-plan.js` using macOS JXA (`osascript`), without adding a
Node.js/Python runtime dependency:

- Group ready images by platform (iOS, tvOS, etc.) and OS major version; keep
  the highest numeric version, then highest build, with a deterministic ID
  tie-break for exact duplicates.
- Independently select deletable images with a valid `lastUsedAt` more than
  30 days old. This can remove the last image of an unused major version.
- Missing usage dates and year-one/zero sentinel dates do not establish old
  usage. Such images remain unless superseded by a newer image in their group.
- Non-deletable images are retained. Any active/unknown device state or
  installing/transitional image defers runtime deletion. Invalid JSON/schema or
  invalid timestamps are errors, not evidence that images are unused.
- Use `xcrun simctl runtime delete <image UUID>`; never delete mounted images
  or runtime directories with `rm`. Re-query devices and recompute eligibility
  immediately before each deletion, and verify the image is absent afterward.
  This does not erase simulator device data; devices may become unavailable
  until the relevant runtime is installed again.

Actual Xcode cleanup (archives, DeviceSupport and runtimes) is deferred while
Xcode, Simulator, build/test/debug or preview processes are active. A failed
process query also blocks Xcode deletion and makes the run fail. Zappy cleanup
can still proceed. Dry-run previews candidates even when Xcode is active and
explicitly reports the deferral; no images or files are deleted.

All directory scans finish successfully before their candidates are processed.
Scan, metadata, sizing, deletion, runtime-query and free-space query failures
are reported and produce a nonzero exit status. A failure in one area does not
prevent independent rules from running. Root symlinks are refused. Xcode
process state is checked again before each removal, but this is not an atomic
lock against an application being launched immediately afterward.

Logs include candidate sizes, successful removal size estimates, free space
before/after, and the observed difference. File sizes use `du -sk`; runtime
sizes use `simctl`'s `sizeBytes`. These are estimates, not promises of physical
space reclaimed: APFS sharing/snapshots and concurrent writes affect `df`.
Dry-run counts candidates separately from actual removals.

Install or refresh the user LaunchAgent with:

```bash
scripts/macos/install-macos-cleanup.sh
```

Both `symlink.py` (on macOS) and the installer link the executable to
`~/.local/bin/cleanup-macos` and the plist to
`~/Library/LaunchAgents/com.karmenzind.macos-cleanup.plist`. Script edits take
effect on the next run without reinstalling. The repository must remain at
the linked location. Existing copied files are replaced with links; `symlink.py`
prompts and backs them up before replacement.

The installer also loads `com.karmenzind.macos-cleanup` in the current GUI user
domain and migrates the old Xcode-only cleanup installation. `symlink.py` only
creates the links; run the installer once to register the LaunchAgent, and
again after changing the plist so launchd reloads its settings. It runs every
259,200 seconds (three days). A `StartInterval` firing that occurs while the Mac
is asleep is missed and is not replayed after waking. Output is appended to
`~/Library/Logs/com.karmenzind.macos-cleanup.log`.

Preview the current candidates without deleting anything:

```bash
~/.local/bin/cleanup-macos --dry-run
```

For isolated tests, `XCODE_ARCHIVES_ROOT` and `XCODE_DEVICE_SUPPORT_ROOT` may
override the two Xcode roots. `--retention-days` may override the Xcode retention
period. To isolate Zappy tests, set `HOME` to a temporary directory.

## Storage review, 2026-11-24

The installed Mole 1.56.1 already implements DerivedData cleanup, user and
system CoreSimulator cache cleanup, and DeviceSupport retention (keeping two
recent versions by default). The custom script's atime-based DeviceSupport
policy differs from Mole's version-count policy. Recheck this overlap after
Mole upgrades before adding more Xcode cache rules here.

The scan-error, active-development and size-reporting findings from this review
are now implemented as described above. The live dry-run selected iOS 18.2
(superseded by 18.5) and iOS 26.5 (`lastUsedAt` 2026-09-11); iOS 18.5 and 27.0
had no reliable usage date and were retained. Xcode was active, so real cleanup
would defer these runtime candidates.

Large device backups and selected wallpaper assets are not disposable caches.
Do not add blanket automatic deletion for MobileSync backups or wallpaper
assets. Review device backups and simulator runtimes through their management
interfaces. Simulator image mount sizes must not be summed as independent
physical disk consumption; use the runtime manager's own size report.

During this review, sandboxed `simctl runtime list` failed to connect to
CoreSimulator, but the same read-only query outside the agent sandbox succeeded
and reported four ready runtimes (33.7G total). `diskutil` similarly required
an unsandboxed query. These sandbox failures did not indicate broken host
services.

## Mole boundary and verified rules (1.56.1)

Mole remains responsible for conventional caches; this LaunchAgent does not
invoke broad `mole clean` automatically. Its public command also cleans logs,
temporary files and app leftovers, and has no cache-only selection flag.
Review `mole clean --dry-run` and its whitelist before a separate Mole cleanup.
Do not source private Mole functions from this script: their setup, guards and
interfaces are internal and version-dependent.

The installed source was inspected for these specific rules:

| Rule | Implementation and protection |
| --- | --- |
| DerivedData | `lib/clean/app_caches.sh: clean_xcode_derived_data`; project-level selection, whitelist/model protections, active or unknown Xcode state defers cleanup, rechecks during removal. |
| User simulator caches | `lib/clean/app_caches.sh: clean_xcode_tools`; bounded Caches/tmp roots with simulator process guards. |
| System simulator caches | `lib/clean/dev.sh: clean_xcode_system_coresimulator_caches`; exact cache root, excludes links/protected entries, active/unknown state defers, privileged removal is handled by Mole. |
| DeviceSupport | `lib/clean/dev.sh: clean_xcode_device_support`; keeps two recent versions by default, respects protected entries, active/unknown Xcode tooling defers cleanup. |
| Spotify cache | `lib/clean/app_caches.sh: clean_media_players`; cache root only, skips when offline downloads are detected. |

This review establishes the listed paths and guards, not blanket safety of
all Mole rules. Reinspect these functions and whitelist behavior after upgrades.
Backups, current wallpaper assets, and arbitrary Application Support data remain
outside unattended cleanup. The custom atime retention for DeviceSupport is
intentionally separate from Mole's keep-two policy.

Verification:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s scripts/tests -p test_macos_cleanup.py -v
bash -n scripts/macos/cleanup-macos.sh
~/.local/bin/cleanup-macos --dry-run --no-log
```

The tests use temporary homes, fake process listings and fake simctl image
registries. They do not delete host runtime images. Real dry-runs must run with
host process/CoreSimulator visibility; an agent sandbox can deny those queries.
