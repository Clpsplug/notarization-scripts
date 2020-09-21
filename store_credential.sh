#!/bin/bash

source "config.sh"

GREEN='\033[01;32m'
YELLOW='\033[01;33m'
RED='\033[01;31m'
RESET='\033[00m'

echo -e "This script initiates the Keychain command for your computer to store your Apple ID credential"
echo -e "for sending your application for notarization."
echo -e "${YELLOW}If you have done this before, you don't need to repeat this step unless you have revoked your password - "
echo -e "in which case you can just Ctrl-C out of this script.${RESET}"

echo ""

echo -e "Provide your Apple ID (usually, your email address:)"
echo -e -n "${GREEN}Apple ID: ${RESET}"
read -r appleid

echo ""

echo -e "Now go to Apple ID website https://appleid.apple.com/ and create an App Specific password"
echo -e "if you haven't done it already!"
echo -e "${YELLOW}Press Return to continue.${RESET}"

# shellcheck disable=SC2034
read -r disposed

echo -e "Provide your App specific password - don't worry, we will NEVER store it anywhere except in your computer!"
echo -e -n "${GREEN}App specific password (hidden): ${RESET}" 
# this stores password in $password
read -sr password

echo ""

xcrun altool --store-password-in-keychain-item "$KEYCHAIN_ITEM_ID" -u "$appleid" -p "$password"

echo -e "\n${GREEN}Stored! Now we will test the credential by listing the providers for this account.${RESET}"

if xcrun altool --list-providers -u "$appleid" -p "@keychain:${KEYCHAIN_ITEM_ID}"; then
	echo -e "${GREEN}Success!${RESET} ${YELLOW}TAKE NOTE OF \"ProviderShortname\" because you'll need it for notarization!!!${RESET}"
	exit 0;
else
	echo -e "${RED}Well, that didn't go as planned...${RESET}"
	echo -e "Check if you have mistyped your password and you have created & entered the App specific password."
	exit 1
fi
