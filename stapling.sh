#!/bin/bash

source "config.sh"

GREEN='\033[01;32m'
YELLOW='\033[01;33m'
RED='\033[01;31m'
RESET='\033[00m'

echo "You must run sign_and_notarize.sh before running this! :)"

echo -e "If you have 'stapled_product' directory here, ${YELLOW}We will delete its contents!${RESET}"

read -n1 -p "ok? (y/N): " yn; case "$yn" in [yY]*) echo "\nProceeding...";; *) exit 1;; esac

rm -rf stapled_product

mkdir stapled_product

xcrun stapler staple "$BINARY_SIGNED" || { echo -e "${RED}Stapling failed!${RESET} Check your notarization status. Is it failing?"; exit 1 }

spctl -a -v "$BINARY_SIGNED" || { echo -e "${RED}Stapling worked but GateKeeper is rejecting?${RESET}"; exit 1; }

echo -e "${GREEN}Stapling GOOD and verified!${RESET}"

mv "$BINARY_SIGNED" stapled_product/

echo "Check stapled_product directory."