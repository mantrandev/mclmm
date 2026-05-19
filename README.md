# mclmm-cli

Lightweight macOS cleaner. Single zsh script, **zero dependencies**.

Inspired by [mac-cleaner-cli](https://github.com/guhcostan/mac-cleaner-cli), rewritten as one ~330-line zsh file (no Node, no Homebrew formula).

## Install

```bash
ln -s "$PWD/mclmm" /usr/local/bin/mclmm   # or anywhere on $PATH
```

### Prefixed commands

Every subcommand is also callable as `mclmm-<subcommand>` (git-style argv[0] dispatch).
The `mclmm-` prefix avoids name collisions with other packages on `$PATH`.

```bash
for s in storage scan cache xcode uninstall big clean; do
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
| `mclmm cache` | Clear user caches, logs, npm/pip caches, then Trash |
| `mclmm xcode` | Clear DerivedData, Archives, iOS/watchOS DeviceSupport, sim caches, unavailable simulators |
| `mclmm uninstall <app>` | Remove an app **and** its caches, prefs, containers, group containers, login items |
| `mclmm big [N]` | N largest files (>50 MB) under `$HOME` (default 20) |
| `mclmm clean` | `cache` + `xcode` |

## Flags

| Flag | Effect |
|---|---|
| `--dry-run` | Show what would be removed, delete nothing |
| `-y`, `--yes` | Skip confirmation prompts |
| `--trash` | Move to `~/.Trash` instead of permanent delete |
| `--system` | Also touch `/Library/Caches` (prompts for sudo) |
| `-h`, `--help` | Help |

## Safety

- **Read-only by default for `scan`/`storage`/`big`.**
- Every destructive command shows total size and asks before deleting; combine with `--dry-run` first.
- `--trash` makes deletions recoverable from Finder.
- System caches require explicit `--system` + sudo; never touched otherwise.

## Beyond the reference project

Additions over mac-cleaner-cli: smart-scan with nested-path de-dup (accurate totals), package-manager cache cleanup, large-file finder, full app-residue uninstall keyed by bundle id, `--trash` recoverable mode, `--dry-run`.
