# barn-claude-jarvis

Claude Code plugin with three reply modes, jarvis, shortmode and friday.

- `jarvis` turns Jarvis mode on: replies get terse and Kokoro reads them
  aloud. `jarvis off` turns it off.
- `shortmode` turns shortmode on: replies get terse, nothing is spoken.
  `shortmode off` turns it off.
- `friday` turns friday mode on: replies on screen stay normal, Claude also
  writes a terse spoken version to
  `~/.cache/barn-claude-jarvis/last-jarvis-message.txt`, and Kokoro reads that
  file aloud. `friday off` turns it off.

Only one mode is on at a time. The marker file
`~/.cache/barn-claude-jarvis/mode` holds the active mode's name; no file means
no mode.

## Hooks

- `UserPromptSubmit` runs `scripts/mode-hook.sh`, which switches the mode and
  restates the active mode's rule beside every prompt.
- `PreToolUse` on `Write` runs `scripts/approve-jarvis-message-write.sh`,
  which approves writes to `~/.cache/barn-claude-jarvis/last-jarvis-message.txt`
  without a permission prompt. The file sits outside `~/.claude` because
  Claude Code always asks before writes to `.claude` folders, whatever a hook
  says.
- `Stop` runs `scripts/write-last-message.sh`, which writes the reply to
  `~/.cache/barn-claude-jarvis/last-message.txt`, then
  `scripts/jarvis-speak.sh`, which speaks that file in Jarvis mode.
  Alongside, `scripts/friday-speak.sh` speaks
  `~/.cache/barn-claude-jarvis/last-jarvis-message.txt` in friday mode, and
  `scripts/friday-stop.sh` sends Claude back once if it did not
  write that file.

All hook scripts take their file paths from `scripts/paths.sh`.

## Requirements

- [`jq`](https://jqlang.org)
- `kokoro` on `PATH`, from [kokoserv](https://github.com/langenhagen/kokoserv)

## Install

```bash
claude plugin marketplace add langenhagen/barn-claude-jarvis
claude plugin install barn-claude-jarvis@barn-claude-jarvis
```

Or from a local clone, run inside the repository:

```bash
claude plugin marketplace add ./
claude plugin install barn-claude-jarvis@barn-claude-jarvis
```

Remove the same hooks from `~/.claude/settings.json`, or they run twice.

## License

See [LICENSE](LICENSE) file.
