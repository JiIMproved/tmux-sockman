#!/usr/bin/env bash

export CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/usr/local/bin:$PATH:/usr/sbin"

export LIST_SESSION_PANE_TITLE="sockman-list-session"

function session_list() {
  session_list_arr=( $(ls -d ~/.ssh/sockman/*/ | xargs -n1 basename) )
  echo "${session_list_arr[@]}"
}

function sockman_session() {
  local session_name=$1
  if [[ -z "${session_name}" ]]; then
    session_name=$(tmux display-message -p '#W')
  fi

  if [[ "$(session_list)" =~ (^|[[:space:]])${session_name}($|[[:space:]]) ]]; then
    echo "${session_name}"
  fi
}

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
