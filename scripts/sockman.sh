#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="/usr/local/bin:$PATH:/usr/sbin"

SESSION_NAME=$(tmux display-message -p '#S')
SESSION_LIST=( $(ls -d ~/.ssh/sockman/*/ | xargs -n1 basename) )

IS_SOCKMAN_SESSION=false
if [[ $SESSION_LIST =~ "(^|[[:space:]])${SESSION_NAME}($|[[:space:]])" ]]; then
  IS_SOCKMAN_SESSION=true
  SOCKET_LIST=($(ls -d ~/.ssh/sockman/${SESSION_NAME}/config.d/*/ | xargs -n1 basename))
else
  SESSION_NAME=""
fi

show_menu() {
  local socket_name=$1

  if [[ $IS_SOCKMAN_SESSION == false ]]; then
    local session_list_args=( $(for arg in "$session_list[@]"; do echo "\"${arg}\" \"\" \"run run\""; done) )

    winid="$(tmux new-window -P bash -c 'source ${CURRENT_DIR}/sockman.sh && list_sessions')"
  elif [[ $socket_name -ne "" ]]; then
    local socket_path="~/.ssh/sockman/${session_name}/${socket_name}/socket"
    local is_socket_open=false
    if [[ -S "$socket_path" ]]; then
      is_socket_open=true
    fi

    winid="$(tmux new-window -P bash -c 'source ${CURRENT_DIR}/sockman.sh && list_sockets_options')"
  else
    winid="$(tmux new-window -P bash -c 'source ${CURRENT_DIR}/sockman.sh && list_sockets')"
  fi
  tmux join-pane -hb -l 40 -s "$winid"
}

function list_sessions() {
  gum style --foreground 212 --bold --height 2 Sockman

  new_session_opt="New session"
  close_menu_opt="Close menu"

  option="$(gum choose $SESSION_LIST $new_session_opt $close_menu_opt)"

  if [[ $option == $new_session_opt ]]; then
    echo hi
    sleep 5
  elif [[ $option == $close_menu_opt ]]; then
    echo bye
    sleep 5
  else
    echo $option
    sleep 5
  fi
}
