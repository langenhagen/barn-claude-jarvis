#!/usr/bin/env bash
# Claude Code PreToolUse hook: let the model write
# ~/.claude/last-jarvis-message.txt without a permission prompt.
#
# The model writes that file itself, every turn, so a prompt for each write
# would interrupt every reply. hooks/hooks.json runs this hook for the Write
# tool only. Any other path falls through to the normal permission flow.
#
# Reads the hook's JSON payload on stdin (`.tool_input.file_path` holds the
# absolute target path). Printing a `permissionDecision` of "allow" skips the
# prompt; printing nothing changes nothing.
#
# author: andreasl

set -euo pipefail

message_file="${HOME}/.claude/last-jarvis-message.txt"

file_path="$(jq -r '.tool_input.file_path // empty')"

[ "${file_path}" = "${message_file}" ] || exit 0

jq -n '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: "barn-claude-jarvis: spoken reply file"
    }
}'
