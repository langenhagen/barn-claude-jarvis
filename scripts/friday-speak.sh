#!/usr/bin/env bash
# Claude Code PostToolUse hook: in Friday mode, read
# ~/.cache/barn-claude-jarvis/last-friday-message.txt aloud with Kokoro.
#
# The model writes that file during its turn (see mode-hook.sh), so speech
# starts right after that Write, before the on-screen reply finishes. Unlike
# Jarvis mode, where write-jarvis-message.sh waits for the transcript, there
# is nothing to wait for. hooks/hooks.json runs this hook for the Write tool
# only; any other path is ignored. A missing file means the model forgot it;
# ensure-friday-message.sh then sends the model back, and the retry's Write
# triggers this hook. `kokoro` blocks until playback ends.
#
# Reads the hook's JSON payload on stdin (`.tool_input.file_path` holds the
# absolute target path).
#
# author: andreasl

set -euo pipefail

# shellcheck source=SCRIPTDIR/paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/paths.sh"

file_path="$(jq -r '.tool_input.file_path // empty')"

[ "${file_path}" = "${friday_message_file}" ] || exit 0

grep --quiet --line-regexp --no-messages friday "${mode_file}" || exit 0

kokoro --speed 1.2 --voice am_echo "${friday_message_file}"
