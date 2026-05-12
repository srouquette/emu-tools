#!/usr/bin/env bash

# Create symlinks from ~ to ${EMU_DIR} when the emulator doesn't use ${EMU_DIR}/storage to store texture packs

source "$HOME/.emu-tools/setenv.sh"

# key = source
# value = target
declare -A symlinks
symlinks["${EMU_DIR}/storage/dolphin-emu"]="/home/deck/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu"
symlinks["${EMU_DIR}/storage/azahar/textures"]="/home/deck/.local/share/azahar-emu/load/textures"

for source in "${!symlinks[@]}"; do
    target="${symlinks[$source]}"

    # 1. Check if source exists
    if [[ ! -e "$source" ]]; then
        echo "Error: Source '$source' does not exist. Skipping."
        continue
    fi

    # 2. Check if destination already exists (as a file, dir, or link)
    if [[ -L "$target" ]]; then
        continue
    fi
    if [[ -e "$target" ]]; then
        echo "Error: Target '$target' exists but isn't a symlink. Delete it before creating the symlink for '$source' ?"
        read -p "Do you want to delete it to create the link for '$source' ? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$target"
            echo "Deleted '$target'."
        else
            echo "Skipping '$target'."
            continue
        fi
    fi

    # 3. Create the link
    ln -s "$source" "$target"
    echo "Linked: $source -> $target"
done
