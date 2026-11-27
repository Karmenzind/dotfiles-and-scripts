# Unix shell configuration boundaries

`home_k/.config/shrc.ext` is shared by bash and zsh. Keep aliases, portable
functions, common environment variables, version-manager initialization, and
project environment synchronization there.

`home_k/.config/fish/` is a third, independent implementation. fish cannot
source `shrc.ext`, so its aliases, environment variables, and custom functions
are re-implemented rather than shared. See [unix-fish.md](./unix-fish.md).

Put configuration that depends on zsh syntax, oh-my-zsh, or a zsh plugin in
`home_k/.zshrc`. This includes:

- oh-my-zsh plugin settings such as `PROJECT_PATHS`;
- zsh-autosuggestions styling;
- FZF zsh options, `_fzf_comprun`, and `pj` completion.

## Browser selection on macOS

On macOS, `shrc.ext` and fish's `conf.d/kz_env.fish` export
`BROWSER="$HOME/.local/bin/open-browser"`. The Vim and Neovim Markdown browser
selectors use the same launcher. `symlink.py` installs it from
`scripts/macos/open-browser.sh` on macOS only. It tries **Chrome, Safari,
Chromium, Firefox**, in that order, using `open -b` with bundle identifiers.
This explicit preference overrides the system default for these CLI/editor
launches and also finds apps installed outside `/Applications`. If a browser
cannot open the URL, the launcher tries the next one; failure of all four
returns a nonzero status. Linux keeps its existing executable lookup order;
Windows retains its Chrome selection.

On 2026-11-24 the system HTTP/HTTPS handler was Chrome, but shell startup found
no `chromium` or `chrome` command and selected Homebrew's `firefox` wrapper.
That exported `BROWSER` overrode the system default in tools such as `gh`.
Chrome's macOS app bundle does not need to provide a `chrome` command.

Already-running shells keep their inherited environment. Start a new shell or
run `export BROWSER="$HOME/.local/bin/open-browser"` (fish:
`set -gx BROWSER "$HOME/.local/bin/open-browser"`).
Explicit `GH_BROWSER`, gh's `browser` configuration, and machine-local overrides
can still take precedence; check those separately when diagnosing recurrence.

## FZF compatibility

The oh-my-zsh `fzf` plugin initializes the zsh integration with `fzf --zsh`.
Do not also source `~/.fzf.zsh` or evaluate `fzf --zsh` from `shrc.ext`.
Doing both installs the same widgets and completion integration more than once.

The `vi-mode` plugin loads after `fzf` and rebinds `Ctrl-R` in the `viins`
keymap to `history-incremental-search-backward`. After all plugins load,
`.zshrc` must explicitly bind `Ctrl-R` back to `fzf-history-widget` in the
`emacs`, `viins`, and `vicmd` keymaps. Do not rely on a second FZF
initialization to restore those bindings.

Set `FZF_TMUX` and `FZF_TMUX_OPTS` only when `fzf-tmux` is installed. FZF's
zsh integration treats either variable as an instruction to call `fzf-tmux`
inside tmux, but does not verify that the command exists. Unconditional values
therefore make widgets such as `fzf-history-widget` fail instead of falling
back to `fzf`.

Before the split, bash sourced `fzf --zsh` from `shrc.ext` and reported a
syntax error near an anonymous zsh function. `bash -n` did not catch the problem
because the invalid code was generated and sourced only at runtime.

The same `FZF_TMUX` rule applies to fish, and so does the same
single-initialization rule: `PatrickF1/fzf.fish` is the only fzf integration
there, and `fzf --fish` must not also be evaluated.

`~/.config/shrc.ext.local` remains a shared local override by explicit choice.
Its contents must be kept bash-compatible if it is expected to load cleanly in
bash; repository checks cannot guarantee compatibility of that machine-local
file. fish also loads it, through `bass source`, so it must stay a plain list of
`export` statements.

## Verification

The split was verified on 2026-07-29 with FZF 0.64.0 and oh-my-zsh commit
`b37dd49c`:

- `zsh -n` passed for `.zshrc` and `shrc.ext`;
- `bash -n` and an isolated bash runtime source of `shrc.ext` passed without
  parsing generated zsh code;
- a real interactive zsh exposed the FZF widget, custom functions and options,
  `pj`, and `fzf-history-widget` as the `Ctrl-R` binding in the main, emacs,
  viins, and vicmd keymaps;
- a tmux-like shell without `fzf-tmux` left `FZF_TMUX` and `FZF_TMUX_OPTS`
  unset, allowing the history widget to use plain `fzf`;
- `pj` activated a temporary project's Python `.venv`.

Revisit the bootstrap boundary if the oh-my-zsh `fzf` plugin stops evaluating
`fzf --zsh`, or if FZF changes the `_fzf_comprun` / `_fzf_complete_*`
customization interfaces.
