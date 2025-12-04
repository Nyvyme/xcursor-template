#!/usr/bin/env /bin/bash

# This file contains all variables which are needed to compile and install
# cursor themes. Feel free to change them.

# Theme name
THEME_NAME="XCursor Template Cursor Theme"

# Theme comment
THEME_COMMENT=""

PATH_THEME_NAME="xcursor_template_theme"

SRC_DIR="src"
FRAMETIMES_DIR="frametimes"
HOTSPOTS_DIR="hotspots"
SYMLINKS_DIR="symlinks"
IMGS_DIR="imgs"
CURSORS_DIR="cursors"
BUILDS_DIR="build"

# Resolutions for which cursor themes will be generated.
# At least one resolution must be provided.
RESOLUTIONS=(16 24 32 48 64 72 80 96 128)

# Default animation time for animated cursors (in ms)
DEFAULT_FRAMETIME=50
