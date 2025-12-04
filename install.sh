#!/usr/bin/env /bin/bash

# If run as root, it will place cursor themes at "/usr/share/icons" directory.
# Otherwise at "$HOME/.local/share/icons".

. vars.sh

install_for_root() {
  echo "Installing all generated cursor themes in /usr/share/icons ..."
  cp -r $BUILDS_DIR/$PATH_THEME_NAME /usr/share/icons
  echo "Installing all generated cursor themes in /usr/share/icons ... DONE"
}

install_for_user() {
  echo "Installing all generated cursor themes in $HOME/.local/share/icons ..."
  cp -r $BUILDS_DIR/$PATH_THEME_NAME $HOME/.local/share/icons
  echo "Installing all generated cursor themes in $HOME/.local/share/icons ... DONE"
}

if [ "$EUID" -ne 0 ]
then
  install_for_user
else
  install_for_root
fi
