#!/usr/bin/env bash

source ./data.sh
source ./panes.sh

function toggle_menu() {
  local pane_id=$(tmux list-panes -F "#{pane_title}" | grep "^sockman-.*" | grep -v "^sockman-primary-.*" | xargs -I {} -n1 tmux list-panes -F "#{pane_id}" -f "#{==:#{pane_title},{}}" 2> /dev/null)
  if [[ -n "${pane_id}" ]]; then
    tmux kill-pane -t "${pane_id}" 2> /dev/null
    return 0
  fi

  local session_name=$(sockman_session)
  if [[ -z "${session_name}" ]]; then
    open_list_sessions_pane
  else
    open_list_sockets_pane "${session_name}"
  fi
}
