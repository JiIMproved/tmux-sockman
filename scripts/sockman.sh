#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="/usr/local/bin:$PATH:/usr/sbin"

show_menu() {
  local socket_name=$1

  local session_name=$(tmux display-message -p '#S')
  local session_list=($(ls -d ~/.ssh/sockman/*/ | xargs -n1 basename))

  local is_sockman_session=false
  if [[ $session_list =~ "(^|[[:space:]])${session_name}($|[[:space:]])" ]]; then
    is_sockman_session=true
    local socket_list=($(ls -d ~/.ssh/sockman/${session_name}/config.d/*/ | xargs -n1 basename))
  else
    session_name=""
  fi

  if [[ $is_sockman_session == false ]]; then
    exit 0
    local session_list_args=($(for arg in "$session_list[@]"; do echo "\"${arg}\" \"\" \"new-session -A -t ${arg}\""; done))
    $(tmux display-menu -T "#[align=centre fg=green]Sockman" -x R -y P \
        $session_list_args \
        "New session"     n "run -b 'source \"$CURRENT_DIR/sockman.sh\" && new_session'" \
        "" \
        "Close menu"       q "" \
    )
  elif [[ $socket_name -ne "" ]]; then
    local socket_path="~/.ssh/sockman/${session_name}/${socket_name}/socket"
    local is_socket_open=false
    if [[ -S "$socket_path" ]]; then
      is_socket_open=true
    fi

    $(tmux display-menu -T "#[align=centre fg=green]Sockman" -x R -y P \
        "-#[nodim]Socket: $socket_name" "" "" \
        "" \
        "Open socket"     o "run -b 'source \"$CURRENT_DIR/sockman.sh\" && open_socket ${arg}'" \
        "Add jump"     j "run -b 'source \"$CURRENT_DIR/sockman.sh\" && add_jump ${arg}'" \
        "Close socket"     c "run -b 'source \"$CURRENT_DIR/sockman.sh\" && close_socket ${arg}'" \
        "" \
        "Open logs"     l "run -b 'source \"$CURRENT_DIR/sockman.sh\" && open_logs ${arg}'" \
        "Search logs"     s "run -b 'source \"$CURRENT_DIR/sockman.sh\" && search_logs ${arg}'" \
        "Open files"     f "run -b 'source \"$CURRENT_DIR/sockman.sh\" && open_files ${arg}'" \
        "" \
        "View info"     i "run -b 'source \"$CURRENT_DIR/sockman.sh\" && view_info ${arg}'" \
        "Edit info"     e "run -b 'source \"$CURRENT_DIR/sockman.sh\" && edit_info ${arg}'" \
        "Rename"     r "run -b 'source \"$CURRENT_DIR/sockman.sh\" && rename_socket ${arg}'" \
        "" \
        "Close menu"       q "" \
    )
  else
    local socket_list_args=($(for arg in "$socket_list[@]"; do echo "\"${arg}\" \"\" \"run -b 'source \"$CURRENT_DIR/sockman.sh\" && show_menu ${arg}'\""; done))
    $(tmux display-menu -T "#[align=centre fg=green]Sockman" -x R -y P \
        "-#[nodim]Session: $session_name" "" "" \
        $socket_list_args \
        "New socket"     n "run -b 'source \"$CURRENT_DIR/sockman.sh\" && new_socket'" \
        "Switch session"     s "run -b 'source \"$CURRENT_DIR/sockman.sh\" && switch_session'" \
        "Destroy session"     "!" "run -b 'source \"$CURRENT_DIR/sockman.sh\" && destroy_session'" \
        "" \
        "Close menu"       q "" \
    )
  fi
}
