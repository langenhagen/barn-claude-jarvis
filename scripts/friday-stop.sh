#!/usr/bin/env bash
# Claude Code Stop hook: in friday mode, send the model back once if it ended
# its turn without writing ~/.claude/last-jarvis-message.txt.
#
# mode-hook.sh deletes that file on every prompt, so a missing file means the
# model forgot this turn. Printing `"decision": "block"` keeps the turn going
# with `reason` as the model's next instruction. `stop_hook_active` is true
# when the turn already continued because of a Stop hook; this hook then lets
# it end, so a model that keeps forgetting cannot loop.
#
# Runs synchronously, since only a synchronous hook can block. friday-speak.sh
# runs alongside and speaks the file once it exists.
#
# author: andreasl

set -euo pipefail

grep --quiet --line-regexp --no-messages friday "${HOME}/.claude/barn-claude-jarvis-mode" || exit 0

message_file="${HOME}/.claude/last-jarvis-message.txt"

[ -f "${message_file}" ] && exit 0
[ "$(jq -r '.stop_hook_active')" = true ] && exit 0

jq -n --arg file "${message_file}" '{
    decision: "block",
    reason: "Friday mode: write the spoken version of your reply to \($file) with the Write tool, then stop without further text."
}'
