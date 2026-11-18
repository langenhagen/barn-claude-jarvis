#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook: switch reply modes and keep the active
# mode's rule in front of the model.
#
# A CLAUDE.md rule is read once at session start and fades as the conversation
# grows, so a mode asked for forty messages ago stops being honoured. This hook
# restates the rule beside every prompt instead, which is the one place the
# model reliably reads.
#
# Modes:
# - jarvis: terse replies, read aloud by jarvis-speak.sh.
# - shortmode: terse replies, nothing spoken.
# - friday: normal replies on screen; the model also writes a short spoken
#   version that makes sense on its own to
#   ~/.cache/barn-claude-jarvis/last-friday-message.txt, which
#   friday-speak.sh reads aloud. This hook deletes that file on every prompt so
#   a stale message is never spoken, and ensure-friday-message.sh makes the
#   model write it if it forgot.
#
# The mode lives in one marker file, ~/.cache/barn-claude-jarvis/mode, which
# holds the mode's name. No file means no mode. One file keeps the modes
# mutually exclusive, since their length rules conflict.
#
# In jarvis and friday mode, the rule also points the model at paths.sh for
# the TTS voice and --prebuffer setting, and defines any request naming
# audio as the destination as writing that content straight to the mode's
# message file.
#
# The user's own words flip it: a prompt of "jarvis", "shortmode" or "friday"
# turns that mode on, the same word plus "off" turns it off if it is the active
# mode. Whitespace and punctuation are stripped and case ignored, so a dictated
# "Jarvis." matches too. The flip happens before the check, so the first reply
# after "jarvis" already follows the rule.
#
# Reads the hook's JSON payload on stdin (its `prompt` field holds the submitted
# text). Plain stdout on exit 0 is added to the model's context for this event.
#
# author: andreasl

set -euo pipefail

script_dir="$(dirname "${BASH_SOURCE[0]}")"
paths_file="${script_dir}/paths.sh"

# shellcheck source=SCRIPTDIR/paths.sh
source "${paths_file}"

mkdir -p "${state_dir}"

prompt="$(jq -r '.prompt // empty' | tr -d '[:space:][:punct:]' | tr '[:upper:]' '[:lower:]')"
mode="$(cat "${mode_file}" 2>/dev/null || true)"

case "${prompt}" in
jarvis | shortmode | friday)
    mode="${prompt}"
    printf '%s\n' "${mode}" >"${mode_file}"
    ;;
jarvisoff | shortmodeoff | fridayoff)
    if [ "${mode}" = "${prompt%off}" ]; then
        mode=""
        rm -f "${mode_file}"
    fi
    ;;
esac

voice_note="Voice (voice_name) and --prebuffer (qtts_prebuffer_seconds) live in ${paths_file} -- other voices under ${voices_dir}; edit to change either. Any 'send/speak/read X to audio' request means writing X"

case "${mode}" in
jarvis)
    printf '%s\n' \
        "Jarvis mode: your reply is read aloud. Answer in a word, yes/no, or at most ~7 words, unless asked for more or truly necessary -- even then, keep it TTS-friendly prose. No explanations, caveats, TL;DR, or follow-ups. Name specifics (which things), not counts or vague refs; brief paraphrases are fine. Do the full work regardless; only the reply is terse. ${voice_note} to ${jarvis_message_file} with the Write tool."
    ;;
shortmode)
    printf '%s\n' \
        'Shortmode is on. Answer in a word, a yes/no, or a fragment of at most about five words, unless asked for more. No explanations, caveats, TL;DR, or follow-up offers. Still do the work behind the answer; only the reply is terse.'
    ;;
friday)
    rm -f "${friday_message_file}"
    printf '%s\n' \
        "Friday mode: your on-screen reply stays full, detailed and normal -- this mode adds nothing there. Separately, as your last tool call before the final reply text, use the Write tool to write a short, standalone spoken version to ${friday_message_file} -- TTS reads it aloud. That spoken version must make sense without seeing the screen and be shorter than the on-screen reply: a yes/no, or 1-3 sentences of ~15 words each. Draft it, then cut about a sixth -- drop every clause, number and aside the listener doesn't need. Use TTS-friendly prose naming things concretely (which skill, line, PR, and what it does), never vague refs like 'the draft', 'one line' or 'that fix'; brief paraphrases are fine. In that spoken file only: explanations/caveats when truly necessary, no TL;DR, no follow-ups. ${voice_note} to ${friday_message_file} instead of the usual short spoken version."
    ;;
esac
