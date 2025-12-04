#!/usr/bin/env /bin/bash

. vars.sh

# Find all .SVG images in source directory
IMGS=()
for FILE_NAME in $(find $SRC_DIR -maxdepth 1 -type f)
do
  if [ ${FILE_NAME/*./} == "svg" ]
  then
    FILE_NAME=${FILE_NAME/.*/}
    FILE_NAME=${FILE_NAME/*$SRC_DIR\//}
    IMGS+=("${FILE_NAME/.*/}")
  fi
done

# Find all directories in source directory.
# Script will assume that these directories
# are directories for animated cursors.
ANIMATED=()
for DIRECTORY_NAME in $(find $SRC_DIR -maxdepth 1 -type d)
do
  DIRECTORY_NAME=${DIRECTORY_NAME/*$SRC_DIR\//}
  if [ "$DIRECTORY_NAME" != "$SRC_DIR" ]
  then
    ANIMATED+=($DIRECTORY_NAME)
  fi
done

if [ ${#IMGS[@]} -eq 0 ] && [ ${#ANIMATED[@]} -eq 0 ]
then
  echo "### No source .SVG images were found in \"$src_dir\" directory."
  echo "### Exitting..."
  exit -1
fi

if [ ${#RESOLUTIONS[@]} -eq 0 ]
then
  echo "### No resolutions were provided in \"vars.sh\" file."
  echo "### Exitting..."
  exit -2
fi

echo "Cursor for these files will be generated:"
for IMG in ${IMGS[*]}
do
  echo "  * $IMG"
done
echo "for resolutions:"
for RES in ${RESOLUTIONS[*]}
do
  echo "  * ${RES}x${RES}"
done

has_command() {
  "$1" -v $1 > /dev/null 2>&1
}

create_dir() {
  echo "Creating \"$1\" directory ..."
  mkdir -p "$1"
  echo "Creating \"$1\" directory ... DONE"
}

# Check if inkscape is installed
echo "Checking if inkscape is installed ..."
if [ ! "$(which inkscape 2> /dev/null)" ]
then
  echo "inkscape must be installed to generate cursors"
  echo "Enter this command to install:"
  if has_command zypper; then
    echo "        sudo zypper in inkscape"
  elif has_command apt; then
    echo "        sudo apt install inkscape"
  elif has_command dnf; then
    echo "        sudo dnf install -y inkscape"
  elif has_command pacman; then
    echo "        sudo pacman -S inkscape"
  else
    echo "### Could not detect package manager!"
    echo "### Reference your distro's packages."
  fi
  exit -1
fi
echo "Checking if inkscape is installed ... DONE"

# Check if bc is installed
echo "Checking if bc is installed ..."
if [ ! "$(which bc 2> /dev/null)" ]
then
  echo "bc must be installed to generate cursors"
  echo "Enter this command to install:"
  if has_command zypper; then
    echo "        sudo zypper in bc"
  elif has_command apt; then
    echo "        sudo apt install bc"
  elif has_command dnf; then
    echo "        sudo dnf install -y bc"
  elif has_command pacman; then
    echo "        sudo pacman -S bc"
  else
    echo "### Could not detect package manager!"
    echo "### Reference your distro's packages."
  fi
fi
echo "Checking if bc is installed ... DONE"

# Check if xcursorgen is installed
echo "Checking if xcursorgen is installed ..."
if [ ! "$(which xcursorgen 2> /dev/null)" ]
then
  echo "xorg-xcursorgen must be installed to generate cursors"
  echo "Enter this command to install:"
  if has_command zypper; then
    echo "        sudo zypper in xorg-xcursorgen"
  elif has_command apt; then
    echo "        sudo apt install xorg-xcursorgen"
  elif has_command dnf; then
    echo "        sudo dnf install -y xorg-xcursorgen"
  elif has_command pacman; then
    echo "        sudo pacman -S xorg-xcursorgen"
  else
    echo "### Could not detect package manager!"
    echo "### Reference your distro's packages."
  fi
fi
echo "Checking if xcursorgen is installed ... DONE"

# Create directory for images
if [ ! -d $IMGS_DIR ]
then
  create_dir $IMGS_DIR
fi

# Create directory for build
if [ ! -d $BUILDS_DIR ]
then
  create_dir $BUILDS_DIR
fi

# Create directory for cursors configs
if [ ! -d $CURSORS_DIR ]
then
  create_dir $CURSORS_DIR
fi

get_hotspot() {
  CUR_NAME=$1
  RES=$2

  # Check if hotspot file exists
  HOTSPOT_FILE="$HOTSPOTS_DIR/$CUR_NAME.hotspot"
  if [ -f $HOTSPOT_FILE ]
  then
    # Read hotspot file
    HOTSPOT_DATA=$(cat "$HOTSPOT_FILE")

    # Get hotspot percents
    HOTSPOT_X_PERCENT=${HOTSPOT_DATA/ */}
    HOTSPOT_Y_PERCENT=${HOTSPOT_DATA/* /}

    # Get hotspot coordinates
    HOTSPOT_X=$(echo "${RES}/100*${HOTSPOT_X_PERCENT}" | bc -l)
    HOTSPOT_X=${HOTSPOT_X/.*/}
    HOTSPOT_Y=$(echo "${RES}/100*${HOTSPOT_Y_PERCENT}" | bc -l)
    HOTSPOT_Y=${HOTSPOT_Y/.*/}
  else
    # Set hotspot to (0;0)
    HOTSPOT_X=0
    HOTSPOT_Y=0
  fi

  echo "$HOTSPOT_X $HOTSPOT_Y" 2>&1
}

generate_static_cursor() {
  CUR_NAME=$1

  echo "Generating cursor \"$CUR_NAME\" ..."

  # Generating images
  CURSOR_CONFIG_DATA=()
  for RES in ${RESOLUTIONS[*]}
  do
    echo "Generating cursor \"$CUR_NAME\" for resolution ${RES}x${RES} ..."

    OUTPUT_IMGS_DIR="$IMGS_DIR/$CUR_NAME"
    IMG_FILE="$OUTPUT_IMGS_DIR/${CUR_NAME}_$RES.png"
    SRC_SVG="$SRC_DIR/$CUR_NAME.svg"

    if [ ! -d "$OUTPUT_IMGS_DIR" ]
    then
      create_dir $OUTPUT_IMGS_DIR
    fi

    # Generate image
    echo "Generating \"$IMG_FILE\" ..."
    inkscape -o "$IMG_FILE" -w $RES -h $RES "$SRC_SVG"
    echo "Generating \"$IMG_FILE\" ... DONE"

    # Get hotspot
    HOTSPOT=$(get_hotspot $CUR_NAME $RES)
    HOTSPOT_X=${HOTSPOT/ */}
    HOTSPOT_Y=${HOTSPOT/* /}

    # Add entry to cursor config
    CURSOR_CONFIG_DATA+=("$RES $HOTSPOT_X $HOTSPOT_Y $IMG_FILE")

    echo "Generating cursor \"$CUR_NAME\" for resolution ${RES}x${RES} ... DONE"
  done

  # Generate cursor config
  CURSOR_CONFIG_FILE="$CURSORS_DIR/$CUR_NAME.cursor"
  echo "Generating cursor config \"$CURSOR_CONFIG_FILE\" ..."
  __BUF=""
  for (( i=0; i < ${#CURSOR_CONFIG_DATA[@]}; i++ ))
  do
    if [ $i -eq 0 ]
    then
      __BUF+="${CURSOR_CONFIG_DATA[$i]}"
    else
      __BUF+="\n${CURSOR_CONFIG_DATA[$i]}"
    fi
  done
  echo -e "$__BUF" > "$CURSOR_CONFIG_FILE"
  unset __BUF
  echo "Generating cursor config \"$CURSOR_CONFIG_FILE\" ... DONE"

  # Generate xcursor
  BUILD_DIR="$BUILDS_DIR/$PATH_THEME_NAME/cursors"
  if [ ! -d "$BUILD_DIR" ]
  then
    create_dir $BUILD_DIR
  fi

  BUILD_FILE="$BUILDS_DIR/$PATH_THEME_NAME/cursors/$CUR_NAME"
  echo "Generating xcursor \"$BUILD_FILE\" ..."
  xcursorgen "$CURSOR_CONFIG_FILE" "$BUILD_FILE"
  echo "Generating xcursor \"$BUILD_FILE\" ... DONE"

  SYMLINKS_FILE="$SYMLINKS_DIR/$CUR_NAME.links"
  # Check if symlinks file is present
  if [ -f "$SYMLINKS_FILE" ]
  then
    # Generate symlinks
    echo "Generating symlinks for cursor \"$CUR_NAME\" ..."
    while read -r LINK_NAME
    do
      cd "$BUILD_DIR"
      if [ ! -f "$LINK_NAME" ]
      then
        echo "Generating symlink \"$LINK_NAME\" to \"$CUR_NAME\" ..."
        ln -sr "$CUR_NAME" "$LINK_NAME"
        echo "Generating symlink \"$LINK_NAME\" to \"$CUR_NAME\" ... DONE"
      fi
      cd "../../.."
    done < "$SYMLINKS_FILE"
    echo "Generating symlinks for cursor \"$CUR_NAME\" ... DONE"
  fi

  echo "Generating cursor \"$CUR_NAME\" ... DONE"
}

generate_animated_cursor() {
  CUR_NAME=$1

  echo "Generating cursor \"$CUR_NAME\" ..."

  SRC_SVG_DIR="$SRC_DIR/$CUR_NAME"

  # Get animation frames
  FRAMES=()
  for FILE_NAME in $(find "$SRC_SVG_DIR" -maxdepth 1 -type f)
  do
    if [ "${FILE_NAME/*./}" == "svg" ]
    then
      FILE_NAME=${FILE_NAME/.*/}
      FILE_NAME=${FILE_NAME/*$SRC_SVG_DIR\//}
      FRAMES+=($FILE_NAME)
    fi
  done

  # Check if there's at least one frame
  if [ ${#FRAMES[@]} -eq 0 ]
  then
    echo "### Animation frames for cursor \"$CUR_NAME\" are missing"
    return
  fi

  # Sort frames
  IFS=$'\n'
  FRAMES=($(sort -V <<< "${FRAMES[*]}"))
  unset IFS

  # Get frametimes
  FRAMETIMES=()
  if [ -f "$FRAMETIMES_DIR/$CUR_NAME.frametime" ]
  then
    while read -r FRAMETIME
    do
      FRAMETIMES+=($FRAMETIME)
    done < "$FRAMETIMES_DIR/$CUR_NAME.frametime"

    if [ ${#FRAMETIMES[@]} -lt ${#FRAMES[@]} ]
    then
      # Number of frame times is less than a number of frames.
      # Add default frametimes
      for (( i=${#FRAMETIMES[@]}; i < ${#FRAMES[@]}; i++ ))
      do
        FRAMETIMES+=($DEFAULT_FRAMETIME)
      done
    elif [ ${#FRAMETIMES[@]} -gt ${#FRAMES[@]} ]
    then
      # Number of frame times is greater than a number of frames.
      # Print warning and remove extra frames
      echo "### Number of frametimes (${#FRAMETIMES[@]})" \
           "is greater than a number of frames (${#FRAMES[@]})"
      echo "### Consider removing extra frames"

      __BUF=()
      for (( i=0; i < ${#FRAMES[@]}; i++ ))
      do
        __BUF+=(${FRAMETIMES[$i]})
      done
      unset FRAMETIMES
      FRAMETIMES=${__BUF[*]}
      unset __BUF
    fi
  else
    # There are no specified frametimes for an animated cursor.
    # Use default frametime.
    for _ in ${FRAMES[*]}
    do
      FRAMETIMES+=($DEFAULT_FRAMETIME)
    done
  fi

  # Generate images and add them into a cursor config
  CURSOR_CONFIG_DATA=()
  for RES in ${RESOLUTIONS[*]}
  do
    OUTPUT_IMGS_DIR="$IMGS_DIR/$CUR_NAME/$RES"
    if [ ! -d "$OUTPUT_IMGS_DIR" ]
    then
      create_dir $OUTPUT_IMGS_DIR
    fi

    # Get hotspot
    HOTSPOT=$(get_hotspot $CUR_NAME $RES)
    HOTSPOT_X=${HOTSPOT/ */}
    HOTSPOT_Y=${HOTSPOT/* /}

    # Generate cursor frame images and add them into a cursor config
    echo "Generating cursor frames for cursor \"$CUR_NAME\" ${RES}x${RES} ..."
    for (( i=0; i < ${#FRAMES[@]}; i++ ))
    do
      FRAME=${FRAMES[$i]}
      FRAMETIME=${FRAMETIMES[$i]}

      echo "[$(( $i + 1 ))/${#FRAMES[@]} frames]" \
        "\"$CUR_NAME\" ${RES}x${RES} cursor ..."

      # Generate image
      inkscape -o "$OUTPUT_IMGS_DIR/$FRAME.png" -w $RES -h $RES "$SRC_SVG_DIR/$FRAME.svg"

      # Add line into a cursor config data
      CURSOR_CONFIG_DATA+=("$RES $HOTSPOT_X $HOTSPOT_Y $OUTPUT_IMGS_DIR/$FRAME.png $FRAMETIME")
    done
    echo "Generating cursor frames for cursor \"$CUR_NAME\" ${RES}x${RES} ..." \
      "DONE"
  done

  # Generate cursor config
  CURSOR_CONFIG_FILE="$CURSORS_DIR/$CUR_NAME.cursor"
  __BUF=""
  for (( i=0; i < ${#CURSOR_CONFIG_DATA[@]}; i++))
  do
    if [ $i -eq 0 ]
    then
      __BUF+="${CURSOR_CONFIG_DATA[$i]}"
    else
      __BUF+="\n${CURSOR_CONFIG_DATA[$i]}"
    fi
  done
  echo -e "$__BUF" > "$CURSOR_CONFIG_FILE"
  unset __BUF

  # Generate xcursor
  BUILD_DIR="$BUILDS_DIR/$PATH_THEME_NAME/cursors"
  if [ ! -d "$BUILD_DIR" ]
  then
    create_dir $BUILD_DIR
  fi

  BUILD_FILE="$BUILDS_DIR/$PATH_THEME_NAME/cursors/$CUR_NAME"
  echo "Generating xcursor \"$BUILD_FILE\" ..."
  xcursorgen "$CURSOR_CONFIG_FILE" "$BUILD_FILE"
  echo "Generating xcursor \"$BUILD_FILE\" ... DONE"

  SYMLINKS_FILE="$SYMLINKS_DIR/$CUR_NAME.links"
  # Check if symlinks file is present
  if [ -f "$SYMLINKS_FILE" ]
  then
    # Generate symlinks
    echo "Generating symlinks for cursor \"$CUR_NAME\" ..."
    while read -r LINK_NAME
    do
      cd "$BUILD_DIR"
      if [ ! -f "$LINK_NAME" ]
      then
        echo "Generating symlink \"$LINK_NAME\" to \"$CUR_NAME\" ..."
        ln -sr "$CUR_NAME" "$LINK_NAME"
        echo "Generating symlink \"$LINK_NAME\" to \"$CUR_NAME\" ... DONE"
      fi
      cd "../../.."
    done < "$SYMLINKS_FILE"
    echo "Generating symlinks for cursor \"$CUR_NAME\" ... DONE"
  fi

  echo "Generating cursor \"$CUR_NAME\" ... DONE"
}

generate_cursors() {
  THEME_DIR="$BUILDS_DIR/$PATH_THEME_NAME"
  if [ ! -d "$THEME_DIR" ]
  then
    create_dir "$THEME_DIR"
  fi

  # Generate static cursors
  for STATIC_CUR in ${IMGS[*]}
  do
    generate_static_cursor $STATIC_CUR
  done

  # Generate animated cursors
  for ANIM_CUR in ${ANIMATED[*]}
  do
    generate_animated_cursor $ANIM_CUR
  done

  # Generate index.theme
  echo "Generating index.theme for theme \"$THEME_NAME\" ..."
  INDEX_THEME="[Icon Theme]\n"
  INDEX_THEME+="Name=${THEME_NAME}\n"
  INDEX_THEME+="Comment=${THEME_COMMENT}\n"
  echo -e "$INDEX_THEME" > "$THEME_DIR/index.theme"
  echo "Generating index.theme for theme \"$THEME_NAME\" ... DONE"
}

generate_cursors
