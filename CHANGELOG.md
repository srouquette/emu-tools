# CHANGELOG

## 1.0.3

- make uninstaller completely offline (was running only 2 commands)
- don't download install.sh, it's only used during update and it's pulled from the repo
- moved the downloadable scripts in .emu-tools, reducing the number of files in the root directory
- mute zenity and replaced some error message with a popup
- rsync_roms: remove zenity progress bar, it was nice but may be hidding some info, added a "job done" popup instead, to check the console
- media_cleaner: added some logs

## 1.0.2

- moved ~/.emu-tools/.env to ~/.config/emu-tools/.env
- reduced duplicated code in install.sh

## 1.0.1

- fix path validation in media_cleaner.sh, to avoid removing files if the path are incorrect.

## 1.0.0

initial release with `rsync_roms.sh` and `media_cleaner.sh`
