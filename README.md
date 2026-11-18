# barn-claude-jarvis

Claude Code plugin with three reply modes: jarvis, shortmode and friday.

- `jarvis` turns Jarvis mode on: replies get terse and TTS, through the
  `qtts` script from [qttsserv](https://github.com/langenhagen/qttsserv),
  reads them aloud. `jarvis off` turns it off.
- `shortmode` turns shortmode on: replies get terse, nothing is spoken.
  `shortmode off` turns it off.
- `friday` turns Friday mode on: replies on screen stay normal, Claude also
  writes a short spoken version that makes sense without the screen to
  `~/.cache/barn-claude-jarvis/last-friday-message.txt`, and TTS reads
  that file aloud. `friday off` turns it off.

Only one mode is on at a time. The marker file
`~/.cache/barn-claude-jarvis/mode` holds the active mode's name; no file means
no mode.

In jarvis and friday mode, Claude also knows it can switch the cloned voice
or change how much `qtts` prebuffers before it starts playing, and that any
request naming audio as the destination ("send a longer text to audio",
"give me a poem on audio", ...) means writing that content straight to the
mode's message file instead of just replying on screen.

## Hooks

- `UserPromptSubmit` runs [`scripts/mode-hook.sh`](scripts/mode-hook.sh),
  which switches the mode and restates the active mode's rule beside every
  prompt.
- `PreToolUse` on `Write` runs
  [`scripts/approve-friday-message-write.sh`](scripts/approve-friday-message-write.sh),
  which approves writes to `~/.cache/barn-claude-jarvis/last-friday-message.txt`
  without a permission prompt.
- `PostToolUse` on `Write` runs
  [`scripts/friday-speak.sh`](scripts/friday-speak.sh), which speaks
  `~/.cache/barn-claude-jarvis/last-friday-message.txt` in Friday mode right
  after Claude writes it.
- `Stop` runs
  [`scripts/write-jarvis-message.sh`](scripts/write-jarvis-message.sh), which
  writes the reply to `~/.cache/barn-claude-jarvis/last-jarvis-message.txt`,
  then [`scripts/jarvis-speak.sh`](scripts/jarvis-speak.sh), which speaks that
  file in Jarvis mode. Alongside,
  [`scripts/ensure-friday-message.sh`](scripts/ensure-friday-message.sh) sends
  Claude back once if it did not write the Friday file.

All hook scripts take their file paths from
[`scripts/paths.sh`](scripts/paths.sh).

## Requirements

- [`jq`](https://jqlang.org)
- `qtts` on `PATH`, from [qttsserv](https://github.com/langenhagen/qttsserv)

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

## Development

Installed from a local clone, the hooks run the scripts in the clone, so
script edits take effect on the next hook run. Claude Code reads
[`hooks/hooks.json`](hooks/hooks.json) from its cached copy of the plugin,
though. After changing that file:

1. Bump `version` in
   [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json).
2. Run `claude plugin update barn-claude-jarvis@barn-claude-jarvis` for each
   install, with `--scope user` or `--scope project`.
3. Start a fresh Claude Code session. `/exit` can leave a background session
   running with the old hooks; end that process too.

## License

See [LICENSE](LICENSE) file.
