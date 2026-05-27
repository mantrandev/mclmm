# mclmm-cli

Lightweight macOS cleaner. Single zsh script, **zero dependencies**.

Inspired by [mac-cleaner-cli](https://github.com/guhcostan/mac-cleaner-cli), rewritten as one self-contained zsh file (no Node, no Homebrew formula).

## Install

```bash
ln -sf "$PWD/mclmm" /usr/local/bin/mclmm   # or anywhere on $PATH
```

### Prefixed commands

Every subcommand is also callable as `mclmm-<subcommand>` (git-style argv[0] dispatch).
The `mclmm-` prefix avoids name collisions with other packages on `$PATH`.

```bash
for s in storage scan xcode cache clean app-list uninstall; do
  ln -sf "$PWD/mclmm" "/usr/local/bin/mclmm-$s"
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
| `mclmm schedule` | Interactive menu — install a launchd job (task, frequency, day, hour) |
| `mclmm schedule list` | List installed mclmm launchd jobs and load status |
| `mclmm schedule remove` | Pick and remove a previously installed schedule |

## Scheduling on CI / runner hosts

Set up an unattended weekly cleanup with `mclmm schedule`. The menu walks through:

1. **Task** — `clean` (default), `cache`, or `xcode`
2. **Frequency** — `weekly` (default) or `daily`
3. **Day** (weekly only) — `Sun` (default) … `Sat`
4. **Hour** — `0`–`23`, default `3`

Output: a launchd plist at `~/Library/LaunchAgents/com.mclmm.<task>.plist` invoking `mclmm <task> -y`. Logs go to `~/Library/Logs/mclmm/<task>.log`. The job is loaded immediately.

Typical CI-runner bootstrap:

```bash
mclmm config add '/Users/gitlab-runner/builds/*/*/DerivedData'
mclmm config add '/Users/gitlab-runner/builds/*/*/.swiftpm'
mclmm schedule              # pick: clean / weekly / Sun / 03:00
```

Inspect or undo:

```bash
mclmm schedule list
mclmm schedule remove
tail -f ~/Library/Logs/mclmm/clean.log
```

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
