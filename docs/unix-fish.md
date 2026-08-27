# Fish shell configuration

fish is a secondary shell here; zsh with oh-my-zsh remains the login shell. The
goal is a broadly unified experience, not a translation of `.zshrc`.

`home_k/.config/shrc.ext` is bash syntax and must stay bash-sourceable, so fish
cannot share it. Aliases, environment variables, and custom functions are
re-implemented in `home_k/.config/fish/` instead. The only thing genuinely
shared is `~/.config/shrc.ext.local`, through `edc/bass`.

## Repository ownership

The repository tracks `config.fish`, `fish_plugins`, and `conf.d/kz_*.fish`.
`functions/`, `completions/`, and `themes/` belong to fisher.

- The `kz_` prefix on every tracked `conf.d` file is mandatory. `fisher update`
  runs `cp -RLf` into `conf.d/`, `functions/`, and `completions/`, and `cp`
  follows a symlinked destination. Fisher 4.4.5 refuses to *install* over an
  existing file but does not check on *update*, so a colliding name would be
  overwritten inside the repository. pure ships `functions/fish_prompt.fish`,
  `fish_greeting.fish`, and `fish_title.fish`, so this is not hypothetical.
- Never add `home_k/.config/fish` to `SYMLINK_AS_DIR` in `symlink.py`. A
  directory symlink would make fisher write plugin files into the repository.
- `fish_plugins` takes no comments. Fisher parses it with
  `string match --regex '^[^\s]+$'`, so a `#` line would be read as a plugin
  name.
- `fisher install` and `fisher remove` rewrite `fish_plugins` through the
  symlink, so plugin changes appear in `git status`. That is intentional.
- Functions are defined in `conf.d` rather than autoloaded from `functions/`.
  The cost is a few microseconds at startup. `funced`/`funcsave` write to
  `functions/` and would shadow them.
- Completions are registered with `complete -c` in the same `conf.d` file. The
  `-a "(...)"` argument is still evaluated lazily at completion time.

## Plugins

| Plugin | Why |
|---|---|
| `jorgebucaran/fisher` | The plugin manager itself; self-managing. |
| `edc/bass` | Runs bash snippets and imports the resulting environment. The only way to keep `~/.config/shrc.ext.local` and `~/.config/secrets/*.env` a single source of truth across bash, zsh, and fish. Requires python3. |
| `pure-fish/pure` | The prompt. |
| `PatrickF1/fzf.fish` | Ctrl-R history, Ctrl-Alt-F directory, Ctrl-Alt-P processes (covering the old `fkill`), Ctrl-Alt-L/S git, Ctrl-V variables. |
| `reitzig/sdkman-for-fish` | Provides the `sdk` command and its completions in fish. `.sdkmanrc` auto-activation is *not* delegated to it; see below. |

fish 4.x is required. `fzf.fish` v11.0 migrated to fish 4.0 binding syntax and
`pure` v4.13.0 documents a Fish 4.1.0+ requirement, so on fish 3.x a
`fisher update` pulls versions that fail at every startup. Ubuntu ships fish
3.x, so `scripts/install_apps.sh` adds `ppa:fish-shell/release-4`.

Do not add `jorgebucaran/nvm.fish`; `AGENTS.md` mandates fnm. Removing it needs
`fisher remove`, not a `fish_plugins` edit, because fisher tracks installed
files in a universal `_fisher_<plugin>_files` variable.

## Key bindings

- `fish_key_bindings` is set as a **global** in `conf.d/kz_keys.fish` so it
  shadows the universal value in the untracked `fish_variables` without
  rewriting it. `__fish_config_interactive` runs on the first `fish_prompt`
  event, after `conf.d` and `config.fish`; its `__init_uvar` uses `set --query`,
  which sees the global and leaves the universal alone, and
  `__fish_reload_key_bindings` then applies the global's value.
- Ctrl-R is **not** bound by this repository. fzf.fish installs it as a *user*
  binding in default and insert mode from its own `conf.d`, and
  `bind --erase --all --preset` inside `fish_vi_key_bindings` erases only preset
  bindings, so it survives and beats the vi preset's `redo`. This is why fish
  needs no equivalent of the explicit Ctrl-R re-bind in `.zshrc`, where the
  `vi-mode` plugin loads after `fzf` and steals the key.
- Ctrl-H, Backspace, and DEL are not bound; fish's vi preset already maps all
  three to `backward-delete-char` in insert mode.
- Ctrl-W is re-bound to `backward-kill-word`. fish's shared preset uses
  `backward-kill-path-component`; zsh's `^W` is `backward-kill-word`.
- The bindings use the `\c` escape notation, not fish 4's readable `ctrl-a`
  names. fish 4 still accepts `\ca`, while fish 3.x parses `ctrl-a` as the
  literal characters `c,t,r,l,-,a` and installs a nonsense binding **without
  erroring** — verified on 3.7.0. One notation that is correct on both versions
  is worth more than the prettier one that silently breaks on the version
  Ubuntu ships.
- Defining `fish_user_key_bindings` in `conf.d/kz_keys.fish` **shadows** any
  autoloaded `~/.config/fish/functions/fish_user_key_bindings.fish`. On this
  machine that file was the entire fzf integration (`fzf --fish | source`), so
  defining the function silently removed every fzf key. Anything that file did
  must be covered by the `conf.d` definition.
- `fish_user_key_bindings` therefore falls back to `fzf --fish | source` when
  `_fzf_search_history` is not defined, i.e. when the fzf.fish plugin is not
  installed yet. When the plugin *is* present the fallback is skipped, so the
  no-double-initialization rule still holds.

## FZF

- Set `FZF_TMUX` and `FZF_TMUX_OPTS` only when `fzf-tmux` exists, for the same
  reason as in [unix-shell-config.md](./unix-shell-config.md): either variable
  instructs fzf to shell out to `fzf-tmux`, and fzf does not check that the
  command is installed. The pre-2026 `config.fish` set both unconditionally.
- Do not run `fzf --fish | source`. fzf.fish is the only integration; running
  both installs the same bindings twice.
- fzf.fish reads its own `fzf_*` variables. `FZF_CTRL_T_OPTS` and
  `FZF_CTRL_R_OPTS` are bash/zsh shell-integration knobs with no effect here.

## PATH

- Use `fish_add_path -gP`. Bare `fish_add_path` writes a universal
  `fish_user_paths` into the untracked `fish_variables`.
- `fish_add_path` returns non-zero when it adds nothing, so never chain it with
  `and`.
- fish does not copy `.zshrc`'s wholesale `PATH` reset. That reset is marked
  `XXX dirty path` in its own source and would drop `~/.local/bin` and fight
  fish's defaults.

## A system-wide /etc/fish/config.fish

fish reads, in order: `conf.d/` snippets, then `$__fish_sysconf_dir/config.fish`
(`/etc/fish/config.fish`), then `$__fish_config_dir/config.fish`. A system-wide
`config.fish` therefore **overrides everything set in `conf.d/`**.

At least one machine has an older copy of this repository's fish configuration
installed there as root. It re-exports `EDITOR`, `PAGER`, `VISUAL`, `FZF_TMUX`,
`FZF_DEFAULT_COMMAND`, and `pure_*`, redefines `y`, prepends
`/opt/miniconda3/bin` and `/root/.dotnet/tools` to `PATH`, and runs `nvm use`.
The conda and nvm parts contradict `AGENTS.md`, and the unconditional
`FZF_TMUX` is the bug this repository documents in `unix-shell-config.md`.

It also sets `pure_symbol_ssh_prefix` to `$USER`. That variable is a *symbol*
printed immediately before `user@host` in SSH sessions and defaults to `""`, so
the prompt rendered as `qk qk@host` — the username twice. `kz_prompt.fish` pins
it back to the default.

Section 5 of `config.fish` re-sources `kz_env`, `kz_fzf`, `kz_prompt`, and
`kz_funcs` when a system-wide `config.fish` exists. Because `config.fish` is the
last file fish reads, this is a purely user-level fix that needs no `sudo` and
leaves the system file untouched. All four snippets are idempotent.

`PATH` cannot be repaired the same way. An untracked
`~/.config/fish/conf.d/conda.fish` installs conda's own shell hook, which
re-adds `/opt/miniconda3/bin` on a later event, so erasing the entry from
`config.fish` does not stick. `scripts/setup_fish.sh` offers to delete that file
instead — the layer where it can actually be fixed.

## Machine-local configuration

- `bass source ~/.config/shrc.ext.local` is the shared source of truth for
  `JAVA_HOME`, `BAT_THEME`, `DPRINT_INSTALL`, `LUA_INCDIR`, and API keys. That
  file contains only `export` lines, which is what makes bass sufficient.
- Do not bass-source `~/.config/shrc.ext` itself. It defines bash functions and
  aliases that cannot transfer, and it overrides `cd`.
- `~/.config/fish/local.fish` stays untracked, for fish-only overrides. It is
  also the right home for personal aliases that are deliberately out of the
  repository's scope.

## Project environments

See [unix-project-environments.md](./unix-project-environments.md) for the
directory-change hooks, including why SDKMAN's global `sdkman_auto_env` switch
is deliberately left off.

## Verification

Syntax, for every tracked file:

```bash
cd "$(git rev-parse --show-toplevel)"
for f in home_k/.config/fish/config.fish home_k/.config/fish/conf.d/kz_*.fish; do
  fish -n "$f" && echo "OK  $f" || echo "FAIL $f"
done
grep -nE '^\s*#' home_k/.config/fish/fish_plugins && echo "FAIL: fisher would parse this as a plugin name"
```

Isolated startup, which never touches the real configuration:

```bash
FISHTEST=$(mktemp -d)
mkdir -p "$FISHTEST/home/.config/fish/conf.d"
cp home_k/.config/fish/config.fish "$FISHTEST/home/.config/fish/"
cp home_k/.config/fish/conf.d/kz_*.fish "$FISHTEST/home/.config/fish/conf.d/"

env -i HOME="$FISHTEST/home" XDG_CONFIG_HOME="$FISHTEST/home/.config" \
       XDG_DATA_HOME="$FISHTEST/home/.local/share" TERM=xterm-256color PATH="$PATH" \
  fish -c 'echo "EDITOR=$EDITOR"; echo "FZF_TMUX=[$FZF_TMUX]";
           for f in ex pj y toboard __kz_sync_python_venv __kz_sync_sdkman_env
               functions -q $f; echo "$f=$status"
           end'
rm -rf "$FISHTEST"
```

`FZF_TMUX=[]` on a machine without `fzf-tmux` is the regression guard for the
bug the old `config.fish` had.

Key bindings, the Python venv hook, fnm's upward resolution, and bass parity
with zsh:

```bash
fish -i -c 'echo $fish_key_bindings; bind -M insert | grep -E "ctrl-[aewpn]\b"'
fish -i -c 'bind -M insert ctrl-r'   # _fzf_search_history, not redo

VT=$(mktemp -d); (cd "$VT" && python3 -m venv .venv && mkdir -p sub/deeper)
fish -i -c "cd $VT/sub/deeper; echo \$VIRTUAL_ENV; cd /tmp; echo [\$VIRTUAL_ENV]"
fish -c "echo (cd $VT; pwd)" 2>&1 | grep -q Activating && echo "FAIL: hook ran in cmdsub"
rm -rf "$VT"

fish -i -c 'functions _fnm_autoload_hook | grep -c "test -f"'   # 0 = recursive strategy
diff <(zsh -ic 'echo $JAVA_HOME; echo $BAT_THEME') <(fish -ic 'echo $JAVA_HOME; echo $BAT_THEME')
fish -i -c 'string match -q "*:*" -- $PATH[1]; and echo "FAIL: colon inside a PATH entry"'
```

Fisher must not be able to write into the repository:

```bash
fish -c 'fisher update'
git status --short home_k/.config/fish/conf.d/   # must print nothing
```

zsh must be unaffected:

```bash
zsh -ic 'bindkey -M viins "^R"; echo "FZF_TMUX=[$FZF_TMUX]"; echo $chpwd_functions'
```

`^R` must still be `fzf-history-widget`, and `chpwd_functions` must contain
`__active_envs` only — that is the assertion proving SDKMAN's global
`sdkman_auto_env` was not enabled.

### Verification record

Checked on 2026-08-23 against fish 3.7.0, fisher 4.4.5, fzf 0.64.0, fnm 1.39.0,
zoxide 0.9.3, SDKMAN 5.22.5 on Ubuntu 24.04.3.

Passing: `fish -n` on all eleven tracked files; `bash -n`/`zsh -n` on
`shrc.ext`; `symlink.py --fishonly` linking every file individually rather than
as a directory; `EDITOR=nvim`, `PAGER=less`, `VISUAL=nvim` and `y` resolving to
`conf.d/kz_funcs.fish` in a live shell despite the system-wide
`/etc/fish/config.fish`; `toboard` reaching `xsel` in both bash and zsh; and zsh
still reporting `^R` as `fzf-history-widget`, `FZF_TMUX=[]`, and
`chpwd_functions` containing `__active_envs` only.

Key bindings were verified under a real pty (`script -qec "fish -i <file>"`);
`fish -i -c` is not sufficient, because it never emits a prompt and therefore
never runs `__fish_config_interactive`, so no key bindings are applied at all.
Under a pty, insert mode reports `\ca beginning-of-line`, `\ce end-of-line`,
`\cp up-or-search`, `\cn down-or-search`, `\cw backward-kill-word`, plus
`\cr fzf-history-widget`, `\ct fzf-file-widget`, and `\ec fzf-cd-widget` in both
default and insert mode.

`FZF_TMUX=1` in fish is correct on this machine: `fzf-tmux` is installed at
`~/.fzf/bin/fzf-tmux`, which fish has on `PATH` through an untracked universal
`fish_user_paths` but zsh does not, because `.zshrc` rebuilds `PATH` from
scratch. The two shells therefore disagree, and each is right by its own rule.

Not yet exercised, because the machine still ran fish 3.7.0 with none of the
plugins installed: the `ctrl-*` bindings, fzf.fish's Ctrl-R surviving
`fish_vi_key_bindings`, `bass` environment parity with zsh, and the SDKMAN hook.
Two questions remain open until then — whether `reitzig/sdkman-for-fish`'s `sdk`
supports the `env` and `env clear` subcommands (if not, `__kz_run_sdkman_env_in`
must parse `.sdkmanrc` and issue `sdk use <candidate> <version>` per line), and
whether fish 4's vi preset still binds backspace in insert mode. Run
`scripts/setup_fish.sh`, work through the commands above, and update this
record.

Revisit this document when fish moves to 5.x (re-check the `bind` notation and
both plugin requirements), when fnm moves past 1.39.0 (re-run
`fnm env --use-on-cd --version-file-strategy recursive --shell fish` and diff
the generated hook), when fisher moves past 4.4.5 (re-check the `cp -RLf`
update path and the `fish_plugins` regex), or when SDKMAN moves past 5.22.5
(re-check `sdkman-init.sh`'s `sdkman_auto_env` block).
