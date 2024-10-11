#!/usr/bin/env bash

export CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/usr/local/bin:$PATH:/usr/sbin"

export SESSION_NAME=$(tmux display-message -p '#S')
export SESSION_LIST=( $(ls -d ~/.ssh/sockman/*/ | xargs -n1 basename) )

export IS_SOCKMAN_SESSION=false
if [[ $SESSION_LIST =~ "(^|[[:space:]])${SESSION_NAME}($|[[:space:]])" ]]; then
  export IS_SOCKMAN_SESSION=true
  export SOCKET_LIST=( $(ls -d ~/.ssh/sockman/${SESSION_NAME}/config.d/*/ | xargs -n1 basename) )
else
  export SESSION_NAME=""
fi

show_menu() {
  local socket_name=$1
  local current_pane_id=$(tmux display-message -p '#{pane_id}')
  echo $CURRENT_DIR
  echo $PATH
  echo $SESSION_NAME
  echo $SESSION_LIST
  echo $IS_SOCKMAN_SESSION
  echo $SOCKET_LIST
  echo $socket_name
  echo $current_pane_id

  if [[ $IS_SOCKMAN_SESSION == false ]]; then
    winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_sessions')"
    echo $winid
  elif [[ $socket_name -ne "" ]]; then
    local socket_path="~/.ssh/sockman/${session_name}/${socket_name}/socket"
    local is_socket_open=false
    if [[ -S "$socket_path" ]]; then
      is_socket_open=true
    fi

    winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_socket_options')"
  else
    winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_sockets')"
  fi
  # tmux join-pane -hb -l 40 -t "$current_pane_id" -s "$winid"
}

function list_sessions() {
  gum style --foreground 212 --bold --height 2 Sockman

  new_session_opt="New session"
  close_menu_opt="Close menu"

  option="$(gum choose $SESSION_LIST "$new_session_opt" "$close_menu_opt")"

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
