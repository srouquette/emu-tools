#!/usr/bin/env bash

source "$HOME/.emu-tools/setenv.sh"

REMOTE_DIR=$REMOTE_USER@$REMOTE_HOST:$REMOTE_EMU_DIR

if [[ ! -d "$EMU_DIR" || -z "$REMOTE_DIR" ]]; then
    zenity --error --title="Uninitialized" --text="Run install.sh" --width=$ZENITY_WIDTH
    exit -1
fi

ans=$(zenity --info --width=$ZENITY_WIDTH \
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
    zenity --width=$ZENITY_WIDTH --height=20 --progress --percentage=0 --text="Copying...." --auto-close --auto-kill --title="Copying $cardname"

echo "done, you can close the window !"
