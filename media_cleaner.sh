#!/usr/bin/env bash

shopt -s nullglob
shopt -s dotglob

source "~/.emu-tools/setenv.sh"

if [ ! -d "$EMU_DIR/downloaded_media" ]; then
  echo -e "$EMU_DIR/downloaded_media not found."
  exit -1
fi

for dir in "$EMU_DIR/downloaded_media/"*; do
  core=$(basename "$dir")
  # if [ "$core" != "snes" ]; then continue; fi
  for file in "$EMU_DIR/downloaded_media/$core/covers/"*; do
    filename=$(basename "$file")
    game="${filename%.*}"
    searchEscaped=$(sed 's/[^^]/[&]/g; s/\^/\\^/g' <<<"$game")
    found=$(find "$EMU_DIR/roms/$core" -regextype egrep -regex ".*$searchEscaped\..{2,4}$" | wc -l)
    if [ $found -eq 0 ]; then
      echo -e "rm $core: $game"
      find "$EMU_DIR/downloaded_media/$core" -regextype egrep -regex ".*$searchEscaped\..{3}$" -delete 2> /dev/null
    fi
  done
done

echo "done, you can close the window !"
