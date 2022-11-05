#!/usr/bin/env bash

GITHUB_REPO=https://raw.githubusercontent.com/srouquette/emu-tools
ZENITY_WIDTH=400

rm -rf ~/Desktop/EmuTools*.desktop 2>/dev/null
rm -rf ~/.emu-tools/*.sh 2>/dev/null
mkdir -p ~/.emu-tools &>/dev/null

curl $GITHUB_REPO/main/install.sh --silent --output ~/.emu-tools/install.sh
curl $GITHUB_REPO/main/setenv.sh --silent --output ~/.emu-tools/setenv.sh
curl $GITHUB_REPO/main/rsync_roms.sh --silent --output ~/.emu-tools/rsync_roms.sh
curl $GITHUB_REPO/main/media_cleaner.sh --silent --output ~/.emu-tools/media_cleaner.sh

echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Uninstall EmuTools
Exec=curl $GITHUB_REPO/main/uninstall.sh | bash -s --
Icon=delete
Terminal=true
Type=Application
StartupNotify=false" > ~/Desktop/EmuToolsUninstall.desktop
chmod +x ~/Desktop/EmuToolsUninstall.desktop

echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Update EmuTools
Exec=curl $GITHUB_REPO/main/install.sh | bash -s --
Icon=bittorrent-sync
Terminal=true
Type=Application
StartupNotify=false" > ~/Desktop/EmuToolsUpdate.desktop
chmod +x ~/Desktop/EmuToolsUpdate.desktop

echo '#!/usr/bin/env xdg-open
[Desktop Entry]
Name=EmuMediaCleaner
Exec=bash ~/.emu-tools/media_cleaner.sh
Icon=sweeper
Terminal=true
Type=Application
StartupNotify=false' > ~/Desktop/EmuToolsMediaCleaner.desktop
chmod +x ~/Desktop/EmuToolsMediaCleaner.desktop

echo '#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Import ROMs
Exec=bash ~/.emu-tools/rsync_roms.sh
Icon=ubiquity-kde
Terminal=true
Type=Application
StartupNotify=false' > ~/Desktop/EmuToolsImportRoms.desktop
chmod +x ~/Desktop/EmuToolsImportRoms.desktop


source "$HOME/.emu-tools/setenv.sh"

if [[ ! -d "$EMU_DIR" ]]; then
    EMU_DIRS=(
        '/home/deck/retrodeck'
        '/home/deck/Emulation'
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
" > ~/.emu-tools/.env
echo -e "after setup:"
cat ~/.emu-tools/.env

if [[ ! -d "$EMU_DIR" || -z "$REMOTE_HOST" || -z "$REMOTE_USER" || -z "$REMOTE_EMU_DIR" ]]; then
    exit -1
fi

if [ ! -f ~/.ssh/id_rsa ] && zenity --question --title="ssh-keygen?" --text="Do you want to generate a new ssh key" --width=$ZENITY_WIDTH 2> /dev/null; then
    ssh-keygen -t rsa -b 4096 -C "steamdeck"
fi

if [ -f ~/.ssh/id_rsa ] && [ -z "$REMOTE_SSH" ] && zenity --question --title="ssh-copy-id?" --text="Do you want to copy your ssh key to $REMOTE_USER@$REMOTE_HOST" --width=$ZENITY_WIDTH 2> /dev/null; then
    REMOTE_SSH=$REMOTE_USER@$REMOTE_HOST
    ssh-copy-id $REMOTE_SSH
    rc=$?
    if [ "$rc" == "0" ]; then echo "REMOTE_SSH=$REMOTE_SSH" >> ~/.emu-tools/.env; fi
fi
