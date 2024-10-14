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
  echo $session_name > ~/stuff

  if [[ -z "${session_name}" ]]; then
    open_list_sessions_pane
  else
    open_list_sockets_pane "${session_name}"
  fi
}

function open_session_window() {
  local session_name=$1
  if [[ -z "${session_name}" ]]; then
    session_name="$(sockman_session)"
  fi

  if [[ -z "${session_name}" ]]; then
    read -p "No session name found. Failed to create or select session window. Press enter to continue."
    return 1
  fi

  tmux new-window -e DISABLE_AUTO_TITLE=true -Sn "${session_name}" 2> /dev/null
  tmux select-pane -T "$(session_primary_pane_title ${session_name})" 2> /dev/null
  tmux setw -g allow-rename off 2> /dev/null
  echo "$(tmux display-message -p '#{pane_id}')"
}
