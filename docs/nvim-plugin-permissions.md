# Neovim plugin Git permissions

## Verified incident: Linux, 2026-11-04

Lazy uses `~/.vim/plugged` in this repository (`plugged_dir` in `init.lua`),
not its usual `~/.local/share/nvim/lazy` path.

Fetching asyncrun.vim failed with:

```
error: insufficient permission for adding an object to repository database .git/objects
fatal: failed to write object
fatal: unpack-objects failed
```

An inspection outside the agent sandbox found 402 root-owned entries across
several plugins, including Git object fanout directories, refs and working
files. The top-level asyncrun.vim directory itself belonged to the user, so
checking only `.git/objects` without its children was insufficient. Disk
space and inode availability were adequate. The process that originally
created the root-owned entries was not identified.

The sandbox mapped foreign-owned entries to `nobody`; verify ownership in the
host environment before concluding that UID 65534 is the actual owner.

The user restored only root-owned entries within the plugin tree:

```bash
sudo find "$HOME/.vim/plugged" -xdev -uid 0 -exec chown -h "$(id -u):$(id -g)" {} +
```

A subsequent host scan found no foreign-owned entries. Running
`git -C ~/.vim/plugged/asyncrun.vim fetch --prune origin` as the normal user
succeeded, advancing `origin/master` from `09b8117` to `98d3c0f`. Fetching did
not change checked-out plugin files or the Lazy lockfile.

## Recurrence

Inspect the effective Lazy root, child-directory ownership, write access,
disk space and filesystem state first. Avoid running Neovim or plugin updates
with sudo, and do not fix this with `chmod -R 777`, deleting plugins or
changing Git's `safe.directory`. Ownership repair addresses this verified
failure; reassess the cause if ownership is already correct. This is local
filesystem state, not a reason to add a platform-wide workaround to `init.lua`.
