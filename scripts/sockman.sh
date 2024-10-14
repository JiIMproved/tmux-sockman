#!/usr/bin/env bash

export CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/usr/local/bin:$PATH:/usr/sbin"

source ${CURRENT_DIR}/data.sh
source ${CURRENT_DIR}/panes.sh

function toggle_menu() {
  if [[ -n "$(remove_sockman_sidebar)" ]]; then
    return 0
  fi

  local session_name=$(sockman_session)
  if [[ -z "${session_name}" ]]; then
    open_list_sessions_pane
  else
    open_list_sockets_pane "${session_name}"
  fi
}
export -f toggle_menu
