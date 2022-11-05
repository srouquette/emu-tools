#!/usr/bin/env bash

source "~/.emu-tools/setenv.sh"

REMOTE_DIR=$REMOTE_USER@$REMOTE_HOST:$REMOTE_EMU_DIR

if [[ ! -d "$EMU_DIR" || -z "$REMOTE_DIR" ]]; then
    zenity --error --title="Uninitialized" --text="Run install.sh" --width=400 2> /dev/null
fi

ans=$(zenity --info --width=400 \
        --title "rsync ROMs" \
        --text "local: $EMU_DIR\nremote: $REMOTE_DIR\noptions: <b>$RSYNC_OPTS</b>" \
        --ok-label "Import" \
        --extra-button "Export" \
        --extra-button "Cancel");

rc=$?
choice="${rc}-${ans}"

if [ "$choice" == "0-" ]; then
    source=$REMOTE_DIR
    target=$EMU_DIR
elif [ "$choice" == "1-Export" ]; then
    source=$EMU_DIR
    target=$REMOTE_DIR
else
    exit
fi

rsync -avu -e ssh "$source/" "$target" $RSYNC_OPTS --info=progress2 |
    tr '\r' '\n' |
    awk '/^ / { print int(+$2) ; fflush() ; next } $0 { print "# " $0 }' |
    zenity --width=400 --height=20 --progress --percentage=0 --text="Copying...." --auto-close --auto-kill --title="Copying $cardname"

echo "done, you can close the window !"
