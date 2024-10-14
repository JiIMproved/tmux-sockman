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

  echo "$(session_list)" > ~/stuff4
  echo "${session_name}" >> ~/stuff4
  if [[ "$(session_list)" =~ (^|[[:space:]])${session_name}($|[[:space:]]) ]]; then
    echo "Success!" >> ~/stuff4
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

function toggle_menu() {
  local pane_id=$(tmux list-panes -F "#{pane_title}" | grep "^sockman-.*" | xargs -I {} -n1 tmux list-panes -F "#{pane_id}" -f "#{==:#{pane_title},{}}" 2> /dev/null)
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

  tmux new-window -Sn "${session_name}" 2> /dev/null
  tmux select-pane -T "$(session_primary_pane_title ${session_name})" 2> /dev/null
  tmux set -w allow-rename off 2> /dev/null
  echo "$(tmux display-message -p '#{pane_id}')"
}

# function open_list_socket_options_pane() {
#   local socket_name=$1
#   if [[ -z "${socket_name}" ]]; then
#     read -p "No socket selected. Failed to create or select pane for socket options. Press enter to continue."
#     return 1
#   fi
#
#   local pane_name="$(socket_options_pane_title ${socket_name})"
#   local pane_found="$(tmux select-pane -t "${pane_name}" && echo true)"
#
#   if [[ -z "${pane_found}" ]]; then
#     local winid="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_socket_options '"${socket_name}")"
#
#     local session_pane_id="$(open_session_window)"
#
#     tmux join-pane -hb -l 40 -t "${session_pane_id}" -s "${winid}"
#
#     # rename current pane so it can be found next time
#     tmux select-pane -T "${pane_name}"
#     tmux set -w allow-rename off
#   fi
# }

# function socket_path() {
#   socket_name=$1
#   if [[ -z "${socket_name}" ]]; then
#     read -p "No socket selected. Failed to get socket path without socket name. Press enter to continue."
#     return 1
#   fi
#
#   local session_name="$(sockman_session)"
#   local socket_path="~/.ssh/sockman/${session_name}/${socket_name}/socket"
#   if [[ -S "${socket_path}" ]]; then
#     echo "${socket_path}"
#   fi
# }

# function list_socket_options() {
#   socket_name=$1
#   if [[ -z "${socket_name}" ]]; then
#     read -p "No socket selected. Failed to list socket options. Press enter to continue."
#     return 1
#   fi
#
#   local is_socket_open=false
#   if [[ -n "$(socket_path "${socket_name}")" ]]; then
#     is_socket_open=true
#   fi
#
#   clear
#   gum style --foreground 212 --bold --height 2 Sockman
#
#   open_socket_opt="Open Socket"
#   add_jump_opt="Add Jump"
#   close_socket_opt="Close Socket"
#   open_logs_opt="Open Logs"
#   search_logs_opt="Search Logs"
#   open_files_opt="Open Files"
#   view_info_opt="View Info"
#   edit_info_opt="Edit Info"
#   rename_opt="Rename"
#   close_menu_opt="Close Menu"
#
#   option="$(gum choose \
#     "$open_socket_opt" \
#     "$add_jump_opt" \
#     "$close_socket_opt" \
#     "$open_logs_opt" \
#     "$search_logs_opt" \
#     "$open_files_opt" \
#     "$view_info_opt" \
#     "$edit_info_opt" \
#     "$rename_opt" \
#     "$close_menu_opt")"
# }

function open_list_sockets_pane() {
  session_name=$1
  local pane_name="$(session_options_pane_title ${session_name})"
  local pane_id=$(tmux list-panes -aF "#{pane_id}" -f "#{==:#{pane_title},"${pane_name}"}" 2> /dev/null)
  local session_pane_id="$(open_session_window ${session_name})"

  if [[ -n "${pane_id}" ]]; then
    tmux select-pane -t "${pane_id}" 2> /dev/null
  else
    pane_id="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_sockets '"${session_name}"'' 2> /dev/null)"
  fi

  tmux join-pane -hb -l 40 -t "${session_pane_id}" -s "${pane_id}" 2> /dev/null

  # rename current pane so it can be found next time
  tmux select-pane -T "${pane_name}" 2> /dev/null
  tmux set -w allow-rename off 2> /dev/null

  echo "${pane_name}"
}

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
    open_list_socket_options_pane "${option}"
  fi
}

function open_list_sessions_pane() {
  local current_pane_id=$(tmux display-message -p '#{pane_id}')

  local pane_name="${LIST_SESSION_PANE_TITLE}"
  local pane_id=$(tmux list-panes -aF "#{pane_id}" -f "#{==:#{pane_title},"${pane_name}"}" 2> /dev/null)

  if [[ -z "${pane_id}" ]]; then
    pane_id="$(tmux new-window -P bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_sessions' 2> /dev/null)"
  else
    tmux respawn-pane -k -t "${pane_id}" bash -c 'source '"${CURRENT_DIR}"'/sockman.sh && list_sessions' 2> /dev/null
  fi
  tmux join-pane -hb -l 40 -t "${current_pane_id}" -s "${pane_id}" 2> /dev/null

  # rename current pane so it can be found next time
  tmux select-pane -T "${pane_name}" 2> /dev/null
  tmux set -w allow-rename off 2> /dev/null
}

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
