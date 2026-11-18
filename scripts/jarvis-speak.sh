#!/usr/bin/env bash
# Claude Code Stop hook: read the last reply aloud while Jarvis mode is on.
#
# Does nothing unless ~/.cache/barn-claude-jarvis/mode holds "jarvis" (see
# mode-hook.sh). Speaks ~/.cache/barn-claude-jarvis/last-jarvis-message.txt,
# which write-jarvis-message.sh writes.
#
# Hooks of one event run in parallel, so hooks/hooks.json chains
# write-jarvis-message.sh and this hook with && to avoid reading the previous
# reply. `qtts` blocks until playback ends.
#
# author: andreasl

set -euo pipefail

# shellcheck source=SCRIPTDIR/paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/paths.sh"

grep --quiet --line-regexp --no-messages jarvis "${mode_file}" || exit 0

qtts --voice "${active_voice_reference}" --transcript "${active_voice_transcript}" --prebuffer "${qtts_prebuffer_seconds}" "${jarvis_message_file}"
