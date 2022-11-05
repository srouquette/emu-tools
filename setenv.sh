#!/usr/bin/env bash

if [ ! -f ~/.emu-tools/.env ]; then exit 0; fi

# Show env vars
grep -v '^#' ~/.emu-tools/.env

# Export env vars
export $(grep -v '^#' ~/.emu-tools/.env | xargs)
