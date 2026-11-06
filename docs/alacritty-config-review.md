# Alacritty configuration review

## Scope and evidence (2026-11-05)

Installed version: Alacritty 0.17.0 (`94e7c887`). This is a review, not an
implemented migration. Alacritty configuration and `symlink.py` were not
changed as part of this review.

### Trace apply behavior before deciding a file is unused

`symlink.py` maps each explicit `TO_SYNC` file with `get_mapped(item)`, but
its directory walk computes `get_mapped(from_dir) / filename` instead of
`get_mapped(src)`. As a result, file-specific entries in `PATH_MAP` are not
honored when a file is reached only through a directory walk.

On Linux, `home_k` is in `TO_SYNC`; `linux.toml` is not explicitly listed.
Although `PATH_MAP` declares `linux.toml -> ~/.config/alacritty/extra.toml`,
the walk emits `~/.config/alacritty/linux.toml`. The common Alacritty config
imports `extra.toml`, not `linux.toml`.

The full Linux `main()` was exercised with its real `TO_SYNC` and directory
walk while mocking link creation and parent-directory creation and enabling
fake mode. It emitted `linux.toml` at its original name and never emitted
`extra.toml`. This proves a path through the apply code, not merely a missing
file in the current home directory. Windows and macOS explicitly list their
platform file and use the direct-file branch, which honors the rename.

Live Linux inspection found no `extra.toml` or `~/.alacritty_extra.toml`.
A read-only `alacritty msg get-config` query returned opacity 1.0, blur false,
and no explicit terminal shell; local font settings were loaded. The
platform-file omission is consistent with the apply behavior. A null shell
means the default shell selection applies; it does not mean no shell starts.

Do not fix this by running the current apply script again unchanged. Decide
between honoring file-level mappings in the directory walk (with regression
coverage for other mappings) and explicitly syncing the Linux platform file.
Neither fix was applied during the review.

### Proposed configuration work

1. Move Windows top-level `shell` to `[terminal].shell` and
   `working_directory` to `[general].working_directory`. The installed
   `alacritty migrate --dry-run --skip-imports` produces these changes.
   Compatibility handling still exists; do not describe the old fields as
   already nonfunctional. Common, Linux and macOS configs already use the
   relevant modern sections. In 0.17.0, the legacy top-level working directory
   takes precedence over `general.working_directory` in `pty_config()`.
   Migrating the Windows field also allows a canonical local override to work
   instead of losing to the legacy `C:/Users` value.
2. Audit the common config's 105 keyboard bindings, including 93 literal
   `chars` mappings. Many reproduce historical standard-key encoding without
   Vi/search restrictions. Prefer removing redundant mappings so the built-in
   handling follows the active keyboard protocol. Preserve deliberate personal
   actions and application-specific workarounds until compared with defaults.
   The public mode parser accepts AppCursor/AppKeypad/Alt/Vi/Search; the
   internal protocol conditions are not configurable mode names. Adding only
   `~Vi|~Search` cannot reproduce all native protocol behavior.
3. Confirm the intention behind Alt+F1–F12 encoding modifier 6 (Ctrl+Shift)
   and Super+F1–F12 encoding modifier 3 (Alt). They differ from the physical
   modifiers. Treat them as suspicious custom mappings, not proof that the
   user never intended the remapping.
4. Clarify scalar override precedence. Imported files are merged in order,
   then the importing parent is merged last. `local.toml` is therefore not a
   universal final override for values also defined in the parent. In 0.17.0,
   array values are appended, not replaced; do not claim that the parent's
   keyboard array discards macOS's Ctrl+/ binding. Any restructuring must
   account for both scalar precedence and combined binding execution. Duplicate
   user bindings are not deduplicated: all matching actions execute. A local
   binding with the same trigger therefore does not simply replace a common
   binding.
5. `blur` is documented for macOS/KDE Wayland. Under i3/X11, compositor
   configuration controls blur. `TERM=xterm-256color` remains a valid
   compatibility choice and is not a required migration. Legacy key names
   such as `Back`, `Key0`, and `Equals` also retain translation in 0.17.0;
   spelling modernization alone is not an urgent correctness fix.

## Sources and revisit conditions

- [Alacritty 0.17.0 release notes](https://alacritty.org/changelog_0_17_0.html)
- [Configuration and import order](https://alacritty.org/config-alacritty.html)
- [0.17.0 migration history](https://github.com/alacritty/alacritty/blob/v0.17.0/CHANGELOG.md)
- [0.17.0 config array merge](https://github.com/alacritty/alacritty/blob/v0.17.0/alacritty/src/config/serde_utils.rs)
- [0.17.0 binding parser and defaults](https://github.com/alacritty/alacritty/blob/v0.17.0/alacritty/src/config/bindings.rs)
- [0.17.0 key encoding](https://github.com/alacritty/alacritty/blob/v0.17.0/alacritty/src/input/keyboard.rs)

Recheck the actual apply branches after changing `symlink.py`. Recheck mode
names, array merge, legacy field handling and default bindings against the
installed version before implementing a future migration. The current Linux
runtime query does not establish effective Windows or macOS behavior.
