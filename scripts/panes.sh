#!/usr/bin/env bash

export CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/usr/local/bin:$PATH:/usr/sbin"

source ${CURRENT_DIR}/data.sh

function open_list_sockets_pane() {
  session_name=$1
  local pane_name="$(session_options_pane_title ${session_name})"
  local pane_id=$(tmux list-panes -aF "#{pane_id}" -f "#{==:#{pane_title},"${pane_name}"}" 2> /dev/null)
  local session_pane_id="$(open_session_window ${session_name})"

  if [[ -n "${pane_id}" ]]; then
    tmux select-pane -t "${pane_id}" 2> /dev/null
  else
    pane_id="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/panes.sh && list_sockets '"${session_name}"'' 2> /dev/null)"
  fi

  tmux join-pane -hb -l 40 -t "${session_pane_id}" -s "${pane_id}" 2> /dev/null

  # rename current pane so it can be found next time
  tmux select-pane -T "${pane_name}" 2> /dev/null
  tmux set -w allow-rename off 2> /dev/null
}
export -f open_list_sockets_pane

function open_list_sessions_pane() {
  local current_pane_id=$(tmux display-message -p '#{pane_id}')

  local pane_name="${LIST_SESSION_PANE_TITLE}"
  local pane_id=$(tmux list-panes -aF "#{pane_id}" -f "#{==:#{pane_title},"${pane_name}"}" 2> /dev/null)

  if [[ -z "${pane_id}" ]]; then
    pane_id="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/panes.sh && list_sessions' 2> /dev/null)"
  else
    tmux respawn-pane -k -t "${pane_id}" bash -c 'source '"${CURRENT_DIR}"'/panes.sh && list_sessions' 2> /dev/null
  fi
  tmux join-pane -hb -l 40 -t "${current_pane_id}" -s "${pane_id}" 2> /dev/null

  # rename current pane so it can be found next time
  tmux select-pane -T "${pane_name}" 2> /dev/null
  tmux set -w allow-rename off 2> /dev/null
}
export -f open_list_sessions_pane

function list_socket_options() {
  socket_name=$1
  if [[ -z "${socket_name}" ]]; then
    read -p "No socket selected. Failed to list socket options. Press enter to continue."
    return 1
  fi

  local is_socket_open=false
  if [[ -n "$(socket_path "${socket_name}")" ]]; then
    is_socket_open=true
  fi

  clear
  gum style --foreground 212 --bold --height 2 Sockman
  printf "socket: "
  gum style --foreground 212 --bold "${socket_name}"

  open_socket_opt="Open Socket"
  add_jump_opt="Add Jump"
  close_socket_opt="Close Socket"
  open_logs_opt="Open Logs"
  search_logs_opt="Search Logs"
  open_files_opt="Open Files"
  view_info_opt="View Info"
  edit_info_opt="Edit Info"
  rename_opt="Rename"
  close_menu_opt="Close Menu"

  option="$(gum choose \
    "$open_socket_opt" \
    "$add_jump_opt" \
    "$close_socket_opt" \
    "$open_logs_opt" \
    "$search_logs_opt" \
    "$open_files_opt" \
    "$view_info_opt" \
    "$edit_info_opt" \
    "$rename_opt" \
    "$close_menu_opt")"
}
export -f list_socket_options

function list_sockets() {
  local session_name=$1

  gum style --foreground 212 --bold --height 2 Sockman

  local new_socket_opt="New Socket"
  local switch_session_opt="Switch Session"
  local close_menu_opt="Close menu"
  local sockets="$(socket_list ${session_name})"

  option="$(gum choose ${sockets} "${new_socket_opt}" "${switch_session_opt}" "${close_menu_opt}")"

  if [[ $option == $new_socket_opt ]]; then
    echo REPLACE
  elif [[ $option == $switch_session_opt ]]; then
    echo REPLACE
  elif [[ $option == $close_menu_opt ]]; then
    echo REPLACE
  else
    list_socket_options "${option}"
  fi
}
export -f list_sockets

function list_sessions() {
  gum style --foreground 212 --bold --height 2 Sockman

  new_session_opt="New session"
  close_menu_opt="Close menu"

  option="$(gum choose "$(session_list)" "$new_session_opt" "$close_menu_opt")"

  if [[ $option == $new_session_opt ]]; then
    echo REPLACE
  elif [[ $option == $close_menu_opt ]]; then
    echo REPLACE
  else
    open_list_sockets_pane "${option}"
  fi
}
export -f list_sessions

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
export -f open_session_window

function remove_sockman_sidebar() {
  local pane_id=$(tmux list-panes -F "#{pane_title}" | grep "^sockman-.*" | grep -v "^sockman-primary-.*" | xargs -I {} -n1 tmux list-panes -F "#{pane_id}" -f "#{==:#{pane_title},{}}" 2> /dev/null)
  if [[ -n "${pane_id}" ]]; then
    tmux kill-pane -t "${pane_id}" 2> /dev/null
    echo "${pane_id}"
  fi
}

function open_list_socket_options_pane() {
  local socket_name=$1
  if [[ -z "${socket_name}" ]]; then
    read -p "No socket selected. Failed to create or select pane for socket options. Press enter to continue."
    return 1
  fi

  local pane_name="$(socket_options_pane_title ${socket_name})"
  local pane_found="$(tmux select-pane -t "${pane_name}" && echo true)"

  if [[ -z "${pane_found}" ]]; then
    local winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/panes.sh && list_socket_options '"${socket_name}")"

    local session_pane_id="$(open_session_window)"

    tmux join-pane -hb -l 40 -t "${session_pane_id}" -s "${winid}"

    # rename current pane so it can be found next time
    tmux select-pane -T "${pane_name}"
    tmux set -w allow-rename off
  fi
}
