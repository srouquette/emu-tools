#!/usr/bin/env bash

export ENV_FILE=~/.config/emu-tools/.env
export ZENITY_WIDTH=400

if [ -f $ENV_FILE ]; then
    # Show env vars
    grep -v '^#' $ENV_FILE

    # Export env vars
    export $(grep -v '^#' $ENV_FILE | xargs)
fi
