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
    local session_list_args=( $(for arg in "$session_list[@]"; do echo "\"${arg}\" \"\" \"run run\""; done) )
    bash -c 'tmux display-menu -T "#[align=centre fg=green]Sockman" -x R -y P '"${session_list_args[@]}"' "New session"     n "run -b '"'"'source \\"$CURRENT_DIR/sockman.sh\\" && new_session'"'"'" "" "Close menu"       q ""'
  fi
}
