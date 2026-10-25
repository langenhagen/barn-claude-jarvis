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
# - friday: normal replies on screen; the model also writes a terse spoken
#   version to ~/.cache/barn-claude-jarvis/last-friday-message.txt, which
#   friday-speak.sh reads aloud. This hook deletes that file on every prompt so
#   a stale message is never spoken, and ensure-friday-message.sh makes the
#   model write it if it forgot.
#
# The mode lives in one marker file, ~/.cache/barn-claude-jarvis/mode, which
# holds the mode's name. No file means no mode. One file keeps the modes
# mutually exclusive, since their length rules conflict.
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

# shellcheck source=SCRIPTDIR/paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/paths.sh"

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

case "${mode}" in
jarvis)
    printf '%s\n' \
        'Jarvis mode is on; your reply is read aloud. Answer in a word, a yes/no, or a fragment of at most about seven words, unless asked for more or really necessary - even then, answer in kokoro-friendly prose always. No explanations, caveats, TL;DR, or follow-up offers. Name the specifics instead of alluding to them: say which things, not only how many or that there are some; a short paraphrase of each is fine. Still do the work behind the answer; only the reply is terse.'
    ;;
shortmode)
    printf '%s\n' \
        'Shortmode is on. Answer in a word, a yes/no, or a fragment of at most about five words, unless asked for more. No explanations, caveats, TL;DR, or follow-up offers. Still do the work behind the answer; only the reply is terse.'
    ;;
friday)
    rm -f "${friday_message_file}"
    printf '%s\n' \
        "Friday mode is on. Reply on screen as you normally would. Also, as your last tool call before the final reply text, use the Write tool to write a spoken version of that reply to ${friday_message_file}; Kokoro reads that file aloud. The spoken version is a word, a yes/no, or a fragment of at most about seven words, unless asked for more or really necessary - even then, kokoro-friendly prose always. No explanations, caveats, TL;DR, or follow-up offers. Name the specifics instead of alluding to them: say which things, not only how many or that there are some; a short paraphrase of each is fine."
    ;;
esac
