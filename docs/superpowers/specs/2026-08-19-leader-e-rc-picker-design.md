# Design: Modernize `<Leader>E` rc file picker

Date: 2026-08-19

## Problem

`<Leader>E` used `vim.fn.confirm()` to pick among rc files (`init.lua`, `vimrc.local`, `vimrc`, `coc.json`). That modal is outdated. Replacing it with stock `vim.ui.select` is only a small step — the default UI is still a plain list.

## Decision

1. Keep `<Leader>E` (and `<Leader>mp`) on `vim.ui.select` with the same labels/paths/open behavior.
2. Add **minimal** `folke/snacks.nvim` so `vim.ui.select` / `vim.ui.input` use the snacks picker/input UI globally.

`dressing.nvim` is archived; its author recommends snacks (or your existing fuzzy finder) instead.

## Behavior (`<Leader>E`)

- Prompt: `To edit:`
- Items: `init.lua`, `vimrc.local`, `vimrc`, `coc.json` (same paths as before)
- On choose: `:e` when the only window is `alpha`/`startify`; otherwise `:vsplit`
- On cancel (Esc / dismiss): no-op
- Presentation: snacks picker (via `picker.ui_select = true`)

## Snacks scope (YAGNI)

Enable only:

- `picker` with `ui_select = true`
- `input` with `enabled = true`

Do **not** enable explorer, dashboard, notifier, indent, scroll, etc. (avoids overlap with alpha, NvimTree, Telescope/fzf).

Plugin load: `priority = 1000`, `lazy = false`, `cond = not vim.g.vscode`.

## Out of scope

- Filtering missing files / showing full paths in the menu
- Replacing Telescope/fzf keymaps with snacks pickers
- Turning on the rest of the snacks suite

## Implementation

- `home_k/.config/nvim/init.lua`: `edit_rc_files_v2` uses `vim.ui.select`; add the snacks plugin entry above.
- No new keymaps.
