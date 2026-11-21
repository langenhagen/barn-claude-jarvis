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
# Each subdirectory of voices/ is a voice. jeff is the default.
# Local settings such as voice_name live in config.sh, which is not under
# version control. Copy config.sh.sample to config.sh to create it.

# For AI agents: a near-miss name is likely a mistype (e.g. "Jana" as
# "Yana") -- use the closest match, don't ask.

voices_dir="$(dirname "${BASH_SOURCE[0]}")/../voices"
config_file="$(dirname "${BASH_SOURCE[0]}")/../config.sh"

voice_name="jeff"
qtts_prebuffer_seconds=0

# Load local settings when config.sh exists. It is local, not in the repository.
# shellcheck source=/dev/null
[[ -f "${config_file}" ]] && source "${config_file}"

# A voice name without a matching directory under voices/ falls back to jeff.
[[ -d "${voices_dir}/${voice_name}" ]] || voice_name="jeff"

active_voice_dir="${voices_dir}/${voice_name}"
active_voice_reference="${active_voice_dir}/reference.wav"
active_voice_transcript="${active_voice_dir}/transcript.txt"

# qtts --prebuffer seconds: how much audio it buffers before it starts
# playing. 0 plays as soon as the first chunk is ready; a higher value
# trades a short delay for fewer potential micro pauses mid-playback
# on a slow machine. Set qtts_prebuffer_seconds in config.sh to change it.
