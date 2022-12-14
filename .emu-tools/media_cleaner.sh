#!/usr/bin/env bash

shopt -s nullglob
shopt -s dotglob

source "$HOME/.emu-tools/setenv.sh"

MEDIA_DIRS=(
    "$EMU_DIR/downloaded_media"
    "$EMU_DIR/tools/downloaded_media"
)
ROMS_DIRS=(
    "$EMU_DIR/roms"
)

for i in "${MEDIA_DIRS[@]}"; do
    if [ -d "$i" ]; then MEDIA_DIR=$i; break; fi
done

if [ ! -d "$MEDIA_DIR" ]; then
  zenity --error --title="Not Found" --text="$EMU_DIR/downloaded_media not found." --width=$ZENITY_WIDTH 2> /dev/null
  exit -1
fi

for i in "${ROMS_DIRS[@]}"; do
    if [ -d "$i" ]; then ROMS_DIR=$i; break; fi
done

if [ ! -d "$ROMS_DIR" ]; then
  zenity --error --title="Not Found" --text="$EMU_DIR/roms not found." --width=$ZENITY_WIDTH 2> /dev/null
  exit -1
fi

for dir in "$MEDIA_DIR/"*; do
  core=$(basename "$dir")
  echo -e "scanning $core..."
  # if [ "$core" != "psx" ]; then continue; fi
  for file in "$MEDIA_DIR/$core/covers/"*; do
    filename=$(basename "$file")
    game="${filename%.*}"
    searchEscaped=$(sed 's/[^^]/[&]/g; s/\^/\\^/g' <<<"$game")
    found=$(find "$ROMS_DIR/$core" -type f -o -type d -regextype egrep -regex ".*$searchEscaped\..{2,4}$" | wc -l)
    if [ $found -eq 0 ]; then
      echo -e "delete media/$core/$game"
      find "$MEDIA_DIR/$core" -regextype egrep -regex ".*$searchEscaped\..{3}$" -delete 2> /dev/null
    fi
  done
done

zenity --info --title="Mission" --text="Complete!" 2> /dev/null
