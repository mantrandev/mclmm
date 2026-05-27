# mclmm-cli

Lightweight macOS cleaner. Single zsh script, **zero dependencies**.

Inspired by [mac-cleaner-cli](https://github.com/guhcostan/mac-cleaner-cli), rewritten as one self-contained zsh file (no Node, no Homebrew formula).

## Install

```bash
ln -s "$PWD/mclmm" /usr/local/bin/mclmm   # or anywhere on $PATH
```

### Prefixed commands

Every subcommand is also callable as `mclmm-<subcommand>` (git-style argv[0] dispatch).
The `mclmm-` prefix avoids name collisions with other packages on `$PATH`.

```bash
for s in storage scan xcode cache clean app-list uninstall; do
  ln -s "$PWD/mclmm" "/usr/local/bin/mclmm-$s"
done
```

Then `mclmm-scan`, `mclmm-clean --dry-run`, `mclmm-uninstall Slack` all work,
identical to `mclmm scan`, `mclmm clean --dry-run`, `mclmm uninstall Slack`.

## Commands

| Command | What it does |
|---|---|
| `mclmm storage` | Disk usage + 12 biggest folders in `$HOME` |
| `mclmm scan` | Read-only. Reclaimable space per category, nested paths de-duplicated |
| `mclmm xcode` | Clear DerivedData, Archives, iOS/watchOS DeviceSupport, sim caches, unavailable simulators |
| `mclmm cache` | Clear user caches, logs, npm/pip caches, then Trash |
| `mclmm clean` | `cache` + `xcode` |
| `mclmm app-list` | List all apps in `/Applications` sorted by size |
| `mclmm uninstall <app>` | Remove an app **and** its caches, prefs, containers, group containers, login items |
| `mclmm config list` | Show extra cache paths (read from `~/.config/mclmm/paths.conf`) |
| `mclmm config add <path-or-glob>` | Add an extra path/glob to clean alongside the defaults |
| `mclmm config remove <path-or-glob>` | Remove an extra path |

## Extra cache paths

For CI/runner hosts whose build caches live outside the macOS defaults, add them once:

```bash
mclmm config add '/Users/gitlab-runner/builds/*/*/DerivedData'
mclmm config add '/Users/gitlab-runner/builds/*/*/.swiftpm'
mclmm config add '/Users/gitlab-runner/builds/*/*/vendor/bundle'
```

Globs are zsh-expanded at scan/clean time. `mclmm scan`, `mclmm cache`, and `mclmm clean` automatically include them. Config lives at `~/.config/mclmm/paths.conf` (one path per line, `#` for comments).

## Flags

| Flag | Effect |
|---|---|
| `--dry-run` | Show what would be removed, delete nothing |
| `-y`, `--yes` | Skip confirmation prompts |
| `--trash` | Move to `~/.Trash` instead of permanent delete |
| `--system` | Also touch `/Library/Caches` (prompts for sudo) |
| `-h`, `--help` | Help |

## Safety

- **Read-only by default for `scan`/`storage`.**
- Every destructive command shows total size and asks before deleting; combine with `--dry-run` first.
- `--trash` makes deletions recoverable from Finder.
- System caches require explicit `--system` + sudo; never touched otherwise.

## Beyond the reference project

Additions over mac-cleaner-cli: smart-scan with nested-path de-dup (accurate totals), package-manager cache cleanup, full app-residue uninstall keyed by bundle id, `--trash` recoverable mode, `--dry-run`.
