#!/usr/bin/env bash

export LIST_SESSION_PANE_TITLE="sockman-list-session"

function session_list() {
  session_list_arr=( $(ls -d ~/.ssh/sockman/*/ | xargs -n1 basename) )
  echo "${session_list_arr[@]}"
}
export -f session_list

function sockman_session() {
  local session_name=$1
  if [[ -z "${session_name}" ]]; then
    session_name=$(tmux display-message -p '#W')
  fi

  if [[ "$(session_list)" =~ (^|[[:space:]])${session_name}($|[[:space:]]) ]]; then
    echo "${session_name}"
  fi
}
export -f sockman_session

function session_options_pane_title() {
  local session_name=$1
  if [[ -z "${session_name}" ]]; then
    session_name="$(sockman_session)"
  fi

  if [[ -z "${session_name}" ]]; then
    read -p "No session name found. Failed to generate session options pane title. Press enter to continue."
    return 1
  fi

  echo "sockman-session-${session_name}"
}
export -f session_options_pane_title

function session_primary_pane_title() {
  local session_name=$1
  if [[ -z "${session_name}" ]]; then
    session_name="$(sockman_session)"
  fi

  if [[ -z "${session_name}" ]]; then
    read -p "No session name found. Failed to generate session primary pane title. Press enter to continue."
    return 1
  fi

  echo "sockman-primary-${session_name}"
}
export -f session_primary_pane_title

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
export -f socket_options_pane_title

function socket_list() {
  session_name=$1
  if [[ -z "${session_name}" ]]; then
    session_name="$(sockman_session)"
  fi

  if [[ -z "${session_name}" ]]; then
    read -p "No session name found. Failed to generate socket list. Press enter to continue."
    return 1
  fi

  local sockets=( $(ls ~/.ssh/sockman/${session_name}/config.d/* | xargs -n1 basename) )
  echo "${sockets[@]}"
}
export -f socket_list
