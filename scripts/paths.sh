# Paths shared by the barn-claude-jarvis hook scripts. Sourced, not run, so a
# move is a change here only.
#
# author: andreasl

# shellcheck shell=bash
# shellcheck disable=SC2034  # SC2034: variable appears unused; the sourcing scripts use them

state_dir="${HOME}/.cache/barn-claude-jarvis"

# The active mode's name; no file means no mode. Written by mode-hook.sh.
mode_file="${state_dir}/mode"

# Jarvis mode: the full reply, written by write-jarvis-message.sh.
jarvis_message_file="${state_dir}/last-jarvis-message.txt"

# Friday mode: the terse spoken version, written by the model itself.
friday_message_file="${state_dir}/last-friday-message.txt"
