#!/bin/bash

# You MUST change those ######################
BINARY_RAW=""  # Your app to sign. This will be left untouched, but will be copied as $BINARY_SIGNED. Relative path recommended.
BINARY_SIGNED=""  # What filename do you want for the signed app?

BUNDLE_ID=""  # Bundle ID for your app. You've set this when you built your app. The example value is intentionally left invalid.

ENTITLEMENTS=""  # Path for your entitlements file. Used to sign your binary as well as included libraries.

APPLE_ID=""  # Your apple id (mostly, the email address.)
SIGNCERT=""  # probably starts with "Developer ID Application:" without quotes.
PROVIDERSHORTNAME="" # You get this when you run store_credential.sh. alternatively run xcrun altool --list-providers -u $APPLE_ID -p "@keychain:${KEYCHAIN_ITEM_ID}"
##############################################

# You CAN change those########################
# shellcheck disable=SC2034
KEYCHAIN_ITEM_ID="AC_PASSWORD"  # you may change this, but you don't really need to.

# shellcheck disable=SC2034
ZIP_NAME="send_for_notarization.zip"  # No need to change it, but you CAN change it to make it more comprehensible 
##############################################

GREEN='\033[01;32m'
RED='\033[01;31m'
RESET='\033[00m'

### Dependency etc. checks

if ! which trash > /dev/null; then
	echo -e "${RED}trash command not found!${RESET}"
	echo "This tool depends on 'trash' command for safe deletion of the previous binary."
	echo "You can install it with your package favorite package manager."
	exit 1;
fi
echo -e "${GREEN}Dependency check OK.${RESET}"

osxVersion=$(sw_vers -productVersion) || { echo -e "${RED}That command shouldn't fail.${RESET} Are you on macOS?"; exit 1; }

IFS=. read -r major minor _ < <(sw_vers -productVersion)

# if x.>=15.z, success. if not, >=11.y.z, success.
if [[ ${minor} -lt 15 && ${major} -le 10 ]]; then
	echo -e "${RED}You need macOS Catalina (10.15.x) or later for these scripts to work.${RESET} You have ${osxVersion}."
	exit 1;
else
	echo -e "${GREEN}macOS version check OK,${RESET} You have ${osxVersion}"
fi

if [[ -z "$BINARY_RAW" || -z "$BINARY_SIGNED" || -z "$ENTITLEMENTS" || -z "$SIGNCERT" || -z "$BUNDLE_ID" || "$BUNDLE_ID" == "com.example.bundle_id" || -z "$APPLE_ID" || "$APPLE_ID" == "example@example.com" ]]; then
	echo -e "${RED}Some of the variable looks unset... did you set everything?${RESET}"
	exit 1;
fi

if [[ -z "$IGNORE_SHORT" && -z "$PROVIDERSHORTNAME" ]]; then
	echo -e "${RED}You need to set provider short name first before you can run this part.${RESET}"
	exit 1;
fi

