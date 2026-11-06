# i3 session startup and configuration

## Configuration entrypoint

The X11 session starts from `home_k/.xinitrc`. Its generated
`~/.config/i3/config.working` defines `$mod` (`Mod1` for an HHKB, `Mod4`
otherwise), then includes `~/.config/i3/config`. On the verified Linux host,
that path is a symlink to `config.magicbook`.

`config`, `config.arch.hhkb`, `config.magicbook`, and `config.tuf` now include
`base`, `common`, and `common-i3`. The machine files contain only hardware
settings. The historical Manjaro configuration retains its distribution
settings and uses `common`; it is not a fifth copy of the new base.

Keep the relative includes: i3 4.25.1 resolves them beside the real symlink
target. This was verified through the existing `config.working` entrypoint;
it does not require creating another live-home symlink for `base`. Normal
`symlink.py` deployment also picks up `base` on Linux. Define variables in the
file using them or in an ancestor before its include: i3 expands the parent
before parsing child includes. An included file cannot supply variables for
subsequent expressions in its parent.

Gap defaults live in `base` and are used both initially and by the reset
bindings. Avoid defining them only in a machine include. The original HHKB
variant also duplicated scratchpad bindings from `common`; the wrappers
remove that duplication.

Additional shortcuts (existing bindings are preserved):

- `$mod+Ctrl+Arrow`: focus the monitor in that direction.
- `$mod+Ctrl+Shift+Arrow`: move the entire workspace in that direction.
- `$mod+Shift+m`: toggle Polybar visibility using its enabled IPC support.

## Startup lifecycle

`common` runs `post_start.sh` with `exec`, not `exec_always`. i3 restarts
therefore preserve services and do not create another scratchpad terminal.
Reloading configuration also does not start services. To apply startup changes
fully, start a new desktop session. An existing xautolock process retains its
old locker command until it is restarted; editing `lock.sh` alone does not
change that argument.

The script skips missing optional programs and checks processes for the
current user before starting them. It no longer uses `killall -9`.
`pamac-tray` and `xflux` were absent on the verified host, with corresponding
command-not-found errors in the i3 log; skipping these is intentional.

Shared notification, authentication, input-method and tray services remain
available under Sway. `SWAYSOCK` together with `WAYLAND_DISPLAY` guards X11
layout, wallpaper, compositor, idle locking, screenshots and Polybar startup.
Do not infer the active compositor by searching for any Sway process.
`POLKIT_AGENT` can override the default Arch authentication-agent path;
tests use an absent temporary path to avoid starting a real desktop agent.

For i3, `~/.screenlayout/default.sh` runs synchronously once, before wallpaper
setup and Polybar monitor enumeration. No `arandr` executable is required to
run an already-generated layout script. The layout failure is reported but
other session startup continues. Initial terminal creation checks the i3 tree
for the existing `my-init-terminal` window.

## Locking and wallpaper

Manual locking and xautolock's 15-minute timeout both use `lock.sh`.
`blurlock` was not installed on the verified host; it is no longer required.
The script selects a readable PNG using NUL-delimited paths, tries
`~/Pictures/LOCKSCREEN.png` as a fallback, and falls back to a solid black lock
if no image is usable or the image-lock command fails. i3 config `set` values
are textual substitutions, not exported shell variables: the script supplies
its own defaults, with optional `WALLPAPER_DIR` and `WALLPAPER_PNG` overrides.
Sway receives swaylock's flags rather than i3lock's flags.

This change does not configure suspend locking; the existing Sway idle-policy
example remains separate. No actual lock or suspend was triggered during the
verification below.

Wallpaper changes follow directory symlinks, support spaces, avoid retry loops,
and accept a single image. The last selection is stored in the user's XDG
cache rather than a shared fixed `/tmp` filename. State updates only after
`feh` succeeds. `ENABLE_ONEKO=1` enables the cat; unset or `0` disables it.

## Polybar

Verified with Polybar 3.7.2. Network modules use its built-in `interface-type`
selection rather than assuming interface indexes 2 and 3. Supplies are detected
from sysfs `type` (`Battery` and `Mains`), ignoring unrelated USB supplies.
A desktop without these supplies can have its battery module disabled by
Polybar; it must not prevent other modules from starting.

Launches are serialized using `flock`. Only the current user's bars receive
SIGTERM, and the launcher waits up to three seconds for them to stop before
starting replacements. Bar children close the launch-lock descriptor. Monitor
names are sorted by RandR x/y position; the third bar uses array index 2.
Run `bash ~/.config/polybar/launch.sh` after changing monitor layout manually.
No output hotplug daemon or new package dependency was added.

The empty `settings.format-spacing`, `format-padding`, `format-margin`, and
`format-offset` entries caused repeated numeric-conversion errors in the host
log. They were removed so defaults apply. Recheck these assumptions when
upgrading Polybar or changing topology, especially vertical monitor layouts.

## Verification (2026-11-04)

- i3 4.25.1: `i3 -C` passes for all four wrappers with `$mod` supplied by a
  temporary parent, and for the actual live `config.working` entrypoint.
- Polybar 3.7.2: configuration parses with `--dump=height single` (20).
- `bash -n` passes for the changed session scripts and `.xinitrc`.
- `python3 scripts/tests/test_i3_session.py`: eight isolated behavior tests
  pass, covering locker fallback, paths containing spaces, both compositor
  branches, oneko, three-monitor selection, supply types, symlink wallpapers,
  startup ordering and existing terminal detection. Desktop programs and
  process-control commands are mocked; these tests do not prove actual
  authentication, rendering or hardware hotplug behavior.
- `git diff --check` passes.

Repeat the parser checks and behavior tests after changing include layout,
startup lifecycle, locking flags, or upgrading i3/Polybar. Validate actual
locking and a new login session separately when desktop interruption is safe.
