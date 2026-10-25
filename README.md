# barn-claude-jarvis

Claude Code plugin with two reply modes, jarvis and shortmode.

- `jarvis` turns Jarvis mode on: replies get terse and Kokoro reads them
  aloud. `jarvis off` turns it off.
- `shortmode` turns shortmode on: replies get terse, nothing is spoken.
  `shortmode off` turns it off.

Only one mode is on at a time. The marker file
`~/.claude/barn-claude-jarvis-mode` holds the active mode's name; no file means
no mode.

## Hooks

- `UserPromptSubmit` runs `scripts/mode-hook.sh`, which switches the mode and
  restates the active mode's rule beside every prompt.
- `Stop` runs `scripts/write-last-message.sh`, which writes the reply to
  `~/.claude/last-message.txt`, then `scripts/jarvis-speak.sh`, which speaks
  that file in Jarvis mode.

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
