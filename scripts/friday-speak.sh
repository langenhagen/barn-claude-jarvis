#!/usr/bin/env bash
# Claude Code Stop hook: in friday mode, read ~/.claude/last-jarvis-message.txt
# aloud with Kokoro.
#
# The model writes that file during its turn (see mode-hook.sh), so it is
# complete when the turn stops and there is no transcript to wait for, unlike
# jarvis-speak.sh. A missing file means the model forgot it; friday-stop.sh
# then sends the model back, and this hook speaks on the next stop. `kokoro`
# blocks until playback ends.
#
# author: andreasl

set -euo pipefail

grep --quiet --line-regexp --no-messages friday "${HOME}/.claude/barn-claude-jarvis-mode" || exit 0

message_file="${HOME}/.claude/last-jarvis-message.txt"

[ -f "${message_file}" ] || exit 0

kokoro --speed 1.2 "${message_file}"
