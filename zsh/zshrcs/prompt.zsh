_prompt_preexec() {
  typeset -gF prompt_command_started=$EPOCHREALTIME
}

_prompt_precmd() {
  # Async Git redraws must retain the time the prompt was first shown.
  typeset -g prompt_time=${(%):-%D{%H:%M:%S}}

  if (( ${+prompt_command_started} )); then
    local -i elapsed=$(( EPOCHREALTIME - prompt_command_started ))
    unset prompt_command_started
    if (( elapsed >= 60 )); then
      osascript -e 'on run argv
        display notification ("実行時間: " & (item 1 of argv) & "秒") with title "コマンド完了"
      end run' "$elapsed" &!
    fi
  fi
  return 0
}

prompt_pure_precustom() {
  psvar[23]=$prompt_time
  psvar[24]=
  prompt_pure_path_segment="%F{${prompt_pure_colors[path]}}%~%f"

  local repo=${prompt_pure_vcs_info[top]}
  local current_path=${PWD:A}
  if [[ -n $repo && ( $repo == / || $current_path == "$repo" || $current_path == "$repo"/* ) ]]; then
    psvar[24]=${${repo:t}:-/}${current_path#"$repo"}
    prompt_pure_path_segment="%F{${prompt_pure_colors[path]}}%24v%f"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd
