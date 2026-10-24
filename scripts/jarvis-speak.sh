#!/usr/bin/env bash
# Claude Code Stop hook: read the last reply aloud with Kokoro while jarvis mode
# is on.
#
# Does nothing unless ~/.claude/jarvis exists (see jarvis-hook.sh).
# Speaks ~/.claude/last-message.txt, which write-last-message.sh
# writes.
#
# Hooks of one event run in parallel, so hooks/hooks.json chains the two
# with && to avoid reading the previous reply. `kokoro` blocks until
# playback ends.
#
# author: andreasl

set -euo pipefail

[ -f "${HOME}/.claude/jarvis" ] || exit 0

kokoro --speed 1.2 "${HOME}/.claude/last-message.txt"
