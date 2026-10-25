#!/usr/bin/env bash
# Claude Code Stop hook: in friday mode, read
# ~/.cache/barn-claude-jarvis/last-friday-message.txt aloud with Kokoro.
#
# The model writes that file during its turn (see mode-hook.sh), so it is
# complete when the turn stops and there is no transcript to wait for, unlike
# jarvis-speak.sh. A missing file means the model forgot it;
# ensure-friday-message.sh then sends the model back, and this hook speaks on
# the next stop. `kokoro` blocks until playback ends.
#
# author: andreasl

set -euo pipefail

# shellcheck source=SCRIPTDIR/paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/paths.sh"

grep --quiet --line-regexp --no-messages friday "${mode_file}" || exit 0

[ -f "${friday_message_file}" ] || exit 0

kokoro --speed 1.2 "${friday_message_file}"
