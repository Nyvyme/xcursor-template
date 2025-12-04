#!/usr/bin/env /bin/bash

# If run as root, it will remove cursor themes at "/usr/share/icons" directory.
# Otherwise at "$HOME/.local/share/icons".

. vars.sh

uninstall_for_root() {
  REMOVE_PATH="/usr/share/icons"
  echo "Removing all \"$PATH_THEME_NAME\"s at $REMOVE_PATH ..."
  rm -rf "$REMOVE_PATH/$PATH_THEME_NAME"
  echo "Removing all \"$PATH_THEME_NAME\"s at $REMOVE_PATH ... DONE"
}

uninstall_for_user() {
  REMOVE_PATH="$HOME/.local/share/icons"
  echo "Removing all \"$PATH_THEME_NAME\"s at $REMOVE_PATH ..."
  rm -rf "$REMOVE_PATH/$PATH_THEME_NAME"
  echo "Removing all \"$PATH_THEME_NAME\"s at $REMOVE_PATH ... DONE"
}

if [ "$EUID" -ne 0 ]
then
  uninstall_for_user
else
  uninstall_for_root
fi
