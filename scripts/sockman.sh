#!/usr/bin/env bash

export CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/usr/local/bin:$PATH:/usr/sbin"

export LIST_SESSION_PANE_TITLE="sockman-list-session"

function session_options_pane_title() {
  local session_name="$(sockman_session)"
  read -p "$(sockman_session). Press enter."
  if [[ -z "${session_name}" ]]; then
    read -p "${session_name}. Press enter."
    read -p "No session name found. Failed to generate session options pane title. Press enter to continue."
    return 1
  fi
  echo "sockman-session-${session_name}"
}

function socket_options_pane_title() {
  socket_name=$1
  if [[ -z "${socket_name}" ]]; then
    read -p "No socket name given. Cannot generate socket options pane title without socket name argument. Press enter to continue."
    return 1
  fi

  session_name="$(sockman_session)"
  if [[ -z "${session_name}" ]]; then
    read -p "No session name found. Failed to generate socket options pane title. Press enter to continue."
    return 1
  fi
  echo "sockman-session-${session_name}"
}

function session_list() {
  session_list_arr=( $(ls -d ~/.ssh/sockman/*/ | xargs -n1 basename) )
  echo "${session_list_arr}"
}

function sockman_session() {
  session_name=$(tmux display-message -p '#W')
  if [[ "$(session_list)" =~ "(^|[[:space:]])${session_name}($|[[:space:]])" ]]; then
    echo "${session_name}"
  fi
}

function socket_list() {
  session_name="$(sockman_session)"
  if [[ -z "${session_name}" ]]; then
    read -p "No session name found. Failed to generate socket list. Press enter to continue."
    return 1
  fi

  socket_list=( $(ls -d ~/.ssh/sockman/${session_name}/config.d/*/ | xargs -n1 basename) )
  echo "${socket_list}"
}

show_menu() {
  local socket_name=$1
  local session_name="$(sockman_session)"

  read -p "Session name: ${session_name}"

  if [[ -z "${session_name}" ]]; then
    open_list_sessions_pane
  elif [[ -n "${socket_name}" ]]; then
    open_list_socket_options_pane "${socket_name}"
  else
    open_list_sockets_pane
  fi
}

function open_session_window() {
  session_name=$1
  if [[ -z "${session_name}" ]]; then
    session_name="$(sockman_session)"
  fi

  if [[ -z "${session_name}" ]]; then
    read -p "No session name found. Failed to create or select session window. Press enter to continue."
    return 1
  fi

  tmux new-window -Sn "${session_name}"
  tmux set -w allow-rename off
  echo "$(tmux display-message -p '#{pane_id}')"
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
    local winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_socket_options '"${socket_name}")"

    local session_pane_id="$(open_session_window)"

    tmux join-pane -hb -l 40 -t "${session_pane_id}" -s "${winid}"

    # rename current pane so it can be found next time
    tmux select-pane -T "${pane_name}"
    tmux set -w allow-rename off
  fi
}

function socket_path() {
  socket_name=$1
  if [[ -z "${socket_name}" ]]; then
    read -p "No socket selected. Failed to get socket path without socket name. Press enter to continue."
    return 1
  fi

  local session_name="$(sockman_session)"
  local socket_path="~/.ssh/sockman/${session_name}/${socket_name}/socket"
  if [[ -S "${socket_path}" ]]; then
    echo "${socket_path}"
  fi
}

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

function open_list_sockets_pane() {
  local pane_name="$(session_options_pane_title)"
  local pane_found="$(tmux select-pane -t "${pane_name}" && echo true)"

  if [[ -z "${pane_found}" ]]; then
    local winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_sockets')"

    local session_pane_id="$(open_session_window)"

    tmux join-pane -hb -l 40 -t "${session_pane_id}" -s "${winid}"

    # rename current pane so it can be found next time
    tmux select-pane -T "${pane_name}"
    tmux set -w allow-rename off
  fi

  echo "${pane_name}"
}

function list_sockets() {
  local session_name=$1
}

function open_list_sessions_pane() {
  local current_pane_id=$(tmux display-message -p '#{pane_id}')

  local pane_name="${LIST_SESSION_PANE_TITLE}"
  local pane_found="$(tmux select-pane -t "${pane_name}" && echo true)"

  if [[ -z "${pane_found}" ]]; then
    local winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_sessions')"

    tmux join-pane -hb -l 40 -t "${current_pane_id}" -s "${winid}"

    # rename current pane so it can be found next time
    tmux select-pane -T "${pane_name}"
    tmux set -w allow-rename off
  else
    tmux join-pane -hb -l 40 -t "${pane_name}" -s "${current_pane_id}"
  fi
}

function list_sessions() {
  gum style --foreground 212 --bold --height 2 Sockman

  new_session_opt="New session"
  close_menu_opt="Close menu"

  option="$(gum choose "$(session_list)" "$new_session_opt" "$close_menu_opt")"

  if [[ $option == $new_session_opt ]]; then
    echo hi
    sleep 5
  elif [[ $option == $close_menu_opt ]]; then
    echo bye
    sleep 5
  else
    local current_pane_id=$(tmux display-message -p '#{pane_id}')
    local pane_id="$(open_session_window ${option})"
    tmux join-pane -hb -l 40 -t "${pane_id}" -s "${current_pane_id}"
    open_list_sockets_pane
  fi
}
