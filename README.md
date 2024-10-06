# Sockman plugin for tmux

Socket manager for tmux

## Installation
### Requirements
* macOS
* tmux >= 3.0

### With Tmux Plugin Manager
Add the plugin in `.tmux.conf`:
```
set -g @plugin 'jiimproved/tmux-sockman'
```
Press `prefix + I` to fetch the plugin and source it. Done.

## Usage
Press tmux `prefix + s` (for example, `C-a s`) and you will see a menu to create a new session:

```
* New session     (n) - create a new session
* Close menu      (q) - close menu
```

If you already have a session created, will offer a list of sessions in the menu:

```
* session1            - selects session1 and opens session menu
* session2            - selects session2 and opens session menu
* sessionc            - selects sessionc and opens session menu
-----------------------------------------
* New session     (n) - create a new session
-----------------------------------------
* Close menu      (q) - close menu
```

If you already have a session selected, will offer a list of sockets to connect to:

```
* ┳▶ socket1          - opens menu for socket1
* ┗━▶ socket1a        - opens menu for socket1a
* ━▶ socket2          - opens menu for socket2
-----------------------------------------
* New Socket      (n) - creates new socket
* Switch session  (s) - Allows you to pick another session to open (all sockets are left open)
* Leave session   (z) - Leave current session (returns to original session before opening sockman, all sockets are left open)
* Destroy session (!) - close current session (destroys all sockets created in session), requires confirmation
-----------------------------------------
* Close menu      (q) - close menu
```

Socket menu:

```
* Open Socket      (o) - creates socket and a new tab connected through the socket (does not create new socket if one already exists)
* Add Jump         (j) - creates new socket jumping from this socket
* Close Socket     (c) - closes socket (and tab if exists)
-----------------------------------------
* Open Logs        (l) - opens logs in $EDITOR
* Search Logs      (s) - searches logs
* Open Files       (f) - opens folder with files grabbed from socket
-----------------------------------------
* View Info        (i) - displays connection information
* Edit Info        (e) - opens connection information in $EDITOR
* Rename           (r) - rename socket (socket must not be open)
-----------------------------------------
* Close menu      (q) - close menu
```

tmux list-windows -F '#I "#W"' | awk '$2 ~ /"qweqwe"/ { print $1 }' | xargs -n1 tmux select-window -t
function sw() { tmux list-windows -F '#I "#W"' | awk -v wname=$1 '$2 ~ wname { print $1 }' | xargs -n1 tmux select-window -t }
