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

# Friday mode: the short spoken version, written by the model itself.
friday_message_file="${state_dir}/last-friday-message.txt"

# TTS voice clone: the reference recording and the words spoken in it.
# Each subdirectory of voices/ is a voice; voice_name picks the active one.
# jeff is the default. Asked to switch voice, change voice_name here.
voices_dir="$(dirname "${BASH_SOURCE[0]}")/../voices"
voice_name="jeff"
active_voice_dir="${voices_dir}/${voice_name}"
active_voice_reference="${active_voice_dir}/reference.wav"
active_voice_transcript="${active_voice_dir}/transcript.txt"

# qtts --prebuffer seconds: how much audio it buffers before it starts
# playing. 0 plays as soon as the first chunk is ready; a higher value
# trades a short delay for fewer potential micro pauses mid-playback
# on a slow machine. When Asked to change the prebuffer, change this
# value.
qtts_prebuffer_seconds=0
