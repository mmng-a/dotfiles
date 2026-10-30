#!/bin/zsh
set -e
zmodload zsh/datetime
zmodload zsh/zselect
source "${0:A:h:h}/zshrcs/prompt.zsh"
preexec_functions=()

test_root=$(mktemp -d)
test_root=${test_root:A}
trap 'if (( ZSH_SUBSHELL == 0 )); then rm -rf -- "$test_root"; fi' EXIT
notification_log=$test_root/notifications
osascript() {
  [[ $1 == -e && $2 == *'display notification'* ]]
  print -r -- "$argv[-1]" >> "$notification_log"
}

_prompt_preexec
(( EPOCHREALTIME - prompt_command_started < 1 ))
prompt_command_started=$(( EPOCHREALTIME - 59.1 ))
_prompt_precmd
[[ ! -e $notification_log ]]
[[ $prompt_time == [0-9][0-9]:[0-9][0-9]:[0-9][0-9] ]]
prompt_command_started=$(( EPOCHREALTIME - 60.1 ))
_prompt_precmd
_prompt_precmd
for attempt in {1..100}; do
  [[ -s $notification_log ]] && break
  zselect -t 1 || true
done
[[ $(<"$notification_log") == 60 ]]

typeset -A prompt_pure_colors=(path blue)
typeset -A prompt_pure_vcs_info
mkdir -p "$test_root/repo/src/components" "$test_root/repo-other" "$test_root/repo%F{red}/sub%~"
prompt_time=12:34:56
prompt_pure_vcs_info[top]=$test_root/repo
cd "$test_root/repo"
prompt_pure_precustom
[[ $psvar[23] == 12:34:56 && $psvar[24] == repo ]]
cd src/components
prompt_pure_precustom
[[ $psvar[24] == repo/src/components ]]
[[ $(print -P -- "$prompt_pure_path_segment") == *repo/src/components* ]]
ln -s "$test_root/repo" "$test_root/link"
cd "$test_root/link/src"
prompt_pure_precustom
[[ $psvar[24] == repo/src ]]
cd "$test_root/repo-other"
prompt_pure_precustom
[[ -z $psvar[24] && $prompt_pure_path_segment == *'%~'* ]]
cd "$test_root/repo%F{red}/sub%~"
prompt_pure_vcs_info[top]=$test_root/repo%F{red}
prompt_pure_precustom
[[ $(print -P -- "$prompt_pure_path_segment") == *'repo%F{red}/sub%~'* ]]
prompt_pure_vcs_info[top]=/
prompt_pure_precustom
[[ $psvar[24] == ${PWD:A} ]]
prompt_pure_vcs_info[top]=
prompt_pure_precustom
[[ -z $psvar[24] && $prompt_pure_path_segment == *'%~'* ]]

print -r -- 'prompt checks passed'
