#!/usr/bin/env bash
# Claude Code Stop hook: read the last reply aloud with Kokoro while Jarvis mode
# is on.
#
# Does nothing unless ~/.cache/barn-claude-jarvis/mode holds "jarvis" (see
# mode-hook.sh). Speaks ~/.cache/barn-claude-jarvis/last-jarvis-message.txt,
# which write-last-message.sh writes.
#
# Hooks of one event run in parallel, so hooks/hooks.json chains the two
# with && to avoid reading the previous reply. `kokoro` blocks until
# playback ends.
#
# author: andreasl

set -euo pipefail

# shellcheck source=SCRIPTDIR/paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/paths.sh"

grep --quiet --line-regexp --no-messages jarvis "${mode_file}" || exit 0

kokoro --speed 1.2 "${jarvis_message_file}"
