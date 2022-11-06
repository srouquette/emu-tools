#!/usr/bin/env bash

GITHUB_REPO=https://raw.githubusercontent.com/srouquette/emu-tools/beta

rm -rf ~/Desktop/EmuTools*.desktop 2>/dev/null
rm -rf ~/.emu-tools 2>/dev/null
mkdir -p ~/.emu-tools &>/dev/null
mkdir -p ~/.config/emu-tools &>/dev/null

# Download files

FILES=(
    'setenv.sh'
    'rsync_roms.sh'
    'media_cleaner.sh'
)

for f in "${FILES[@]}"; do
    curl $GITHUB_REPO/.emu-tools/$f --silent --output ~/.emu-tools/$f
    chmod +x ~/.emu-tools/$f
done

# Create Icons

# file, name, icon, exec
function create_desktop_icon {
echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Name=$2
Icon=$3
Exec=$4
Terminal=true
Type=Application
StartupNotify=false" > ~/Desktop/$1
chmod +x ~/Desktop/$1
}

create_desktop_icon "EmuToolsUninstall.desktop" "Uninstall EmuTools" "delete" \
    "{ rm -rf ~/.emu-tools && rm -rf ~/Desktop/EmuTools*.desktop; } 2>/dev/null"

create_desktop_icon "EmuToolsUpdate.desktop" "Update EmuTools" "bittorrent-sync" \
    "curl $GITHUB_REPO/install.sh | bash -s --"

create_desktop_icon "EmuToolsMediaCleaner.desktop" "EmuMediaCleaner" "sweeper" \
    "bash ~/.emu-tools/media_cleaner.sh"

create_desktop_icon "EmuToolsImportRoms.desktop" "Import ROMs" "ubiquity-kde" \
    "bash ~/.emu-tools/rsync_roms.sh"

source "$HOME/.emu-tools/setenv.sh"
if [ -f ~/.emu-tools/.env ] && [ ! -z "$ENV_FILE" ]; then mv ~/.emu-tools/.env $ENV_FILE; fi

# Configure

if [[ ! -d "$EMU_DIR" ]]; then
    EMU_DIRS=(
        '/home/deck/retrodeck'
        '/home/deck/.emulationstation'
        '/home/deck/Emulation'
        '/run/media/mmcblk0p1/Emulation'
        '/Emulation'
    )
    for emu_dir in "${EMU_DIRS[@]}"; do
        if [ -d "$emu_dir" ]; then EMU_DIR=$emu_dir; break; fi
    done

    if [ -z "$EMU_DIR" ]; then
        EMU_DIR=$(zenity --file-selection --directory --title="Emulation directory" --width=$ZENITY_WIDTH)
    fi
fi

if [ -z "$REMOTE_HOST" ]; then
    REMOTE_HOST=$(zenity --entry --title="Remote host" --text="IP address:" --entry-text "192.168.2.8" --width=$ZENITY_WIDTH)
fi

if [ -z "$REMOTE_USER" ]; then
    REMOTE_USER=$(zenity --entry --title="Username" --text="Username:" --entry-text "pi" --width=$ZENITY_WIDTH)
fi

if [ -z "$REMOTE_EMU_DIR" ]; then
    REMOTE_EMU_DIR=$(zenity --entry --title="Remote directory" --text="Directory on the remote server:" --entry-text "/mnt/Elements/shared/retrodeck" --width=$ZENITY_WIDTH)
fi

if zenity --question --title="rsync options" --text="--delete-after?" --width=$ZENITY_WIDTH 2> /dev/null; then
    RSYNC_OPTS=--delete-after
fi

echo "
EMU_DIR=$EMU_DIR
REMOTE_HOST=$REMOTE_HOST
REMOTE_USER=$REMOTE_USER
REMOTE_EMU_DIR=$REMOTE_EMU_DIR
RSYNC_OPTS=$RSYNC_OPTS
REMOTE_SSH=$REMOTE_SSH
" > $ENV_FILE

echo -e "after setup:"
cat $ENV_FILE

if [[ ! -d "$EMU_DIR" || -z "$REMOTE_HOST" || -z "$REMOTE_USER" || -z "$REMOTE_EMU_DIR" ]]; then
    echo -e "some env were not properly configured."
    exit -1
fi

if [ ! -f ~/.ssh/id_rsa ] && zenity --question --title="ssh-keygen?" --text="Do you want to generate a new ssh key" --width=$ZENITY_WIDTH 2> /dev/null; then
    ssh-keygen -t rsa -b 4096 -C "steamdeck"
fi

if [ -f ~/.ssh/id_rsa ] && [ -z "$REMOTE_SSH" ] && zenity --question --title="ssh-copy-id?" --text="Do you want to copy your ssh key to $REMOTE_USER@$REMOTE_HOST" --width=$ZENITY_WIDTH 2> /dev/null; then
    REMOTE_SSH=$REMOTE_USER@$REMOTE_HOST
    ssh-copy-id $REMOTE_SSH
    rc=$?
    if [ "$rc" == "0" ]; then echo "REMOTE_SSH=$REMOTE_SSH" >> $ENV_FILE; fi
fi
