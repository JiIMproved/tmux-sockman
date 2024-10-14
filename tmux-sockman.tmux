#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="/usr/local/bin:$PATH:/usr/sbin"

main() {
  $(tmux bind-key -T prefix s run-shell -b "source ${CURRENT_DIR}/scripts/sockman.sh && toggle_menu")
}

main
