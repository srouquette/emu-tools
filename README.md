# EmuTools
ROMs synchronization and media cleaner for RetroDeck and EmuDeck.

## Features

- EmuMediaCleaner: remove orphan media files (covers, videos). This can occur if you delete a ROM without using EmulationStation-DE to delete it properly.
- Import ROMs: Import/Export ROMs to a remote PC via SSH, synchronize your emulation directory remotely.

## Install

Download EmuToolsInstall.desktop from this repository with [this link](https://raw.githubusercontent.com/srouquette/emu-tools/main/EmuToolsInstall.desktop) on your Steam Deck, then run it. (Right click and save file)

During the installation, you will be asked to configure some informations:

- the directory where your RetroDeck or EmuDeck is installed, if the script can't detect it automatically. (ex: ~/retrodeck)
- the IP address of the remote host
- the username to connect to the remote host
- the directory where the roms will be stored on the remote host (ex: ~/retrodeck)
- if the synchronization should delete the files if they are deleted locally (rsync --delete-after)
- if we should generate a ssh key and copy it to the remote host, this allows to connect without entering your password everytime

## Upgrade
Double-click the "Update EmuTools" icon on the desktop.

## Uninstall
Double-click the "Uninstall EmuTools" icon on the desktop.
