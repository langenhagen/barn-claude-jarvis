#!/usr/bin/env bash
# Claude Code PreToolUse hook: let the model write
# ~/.cache/barn-claude-jarvis/last-jarvis-message.txt without a permission
# prompt.
#
# The model writes that file itself, every turn, so a prompt for each write
# would interrupt every reply. The file lives outside ~/.claude because
# Claude Code's protection of .claude folders overrides this hook's "allow".
# hooks/hooks.json runs this hook for the Write tool only. Any other path falls
# through to the normal permission flow.
#
# Reads the hook's JSON payload on stdin (`.tool_input.file_path` holds the
# absolute target path). Printing a `permissionDecision` of "allow" skips the
# prompt; printing nothing changes nothing.
#
# author: andreasl

set -euo pipefail

# shellcheck source=SCRIPTDIR/paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/paths.sh"

file_path="$(jq -r '.tool_input.file_path // empty')"

[ "${file_path}" = "${friday_message_file}" ] || exit 0

jq -n '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: "barn-claude-jarvis: spoken reply file"
    }
}'
