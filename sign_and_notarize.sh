#!/bin/bash

source "config.sh"

GREEN='\033[01;32m'
YELLOW='\033[01;33m'
RED='\033[01;31m'
RESET='\033[00m'


######################## Actual code, no need to edit unless you know what you're doing :) ########################

echo -e "Moving the previously signed binary to trash"
if [ -f "${BINARY_SIGNED}" ]; then
	trash -F "${BINARY_SIGNED}" || { echo "${RED}Remove failure${RESET} You might want to give this terminal 'Automation' permission from System Preferences."; exit 1; }
fi

echo -e "Copying binary to work on..."
cp -r "$BINARY_RAW" "$BINARY_SIGNED"

echo -e "Stripping meta file"

find "./$BINARY_SIGNED" -name "*.meta" -type f -exec rm {} \;

echo -e "Giving xr permission to everything in the binary"
chmod -R a+xr "$BINARY_SIGNED"

echo -e "Signing Dylib"
libfile=$(find "./$BINARY_SIGNED" -name '*.dylib')
if [ -n "$libfile" ]; then
	while read -r libname; do
		echo -e "${GREEN}Sign:" "$libname" "$RESET"
		codesign --deep --force --verify -vvvv --timestamp --options runtime --entitlements  "$ENTITLEMENTS" --sign "$SIGNCERT" "$libname" || { echo -e "${RED}Codesign failure!${RESET}"; exit 1; }
		
	done <<< "$libfile"
else
    echo -e "${YELLOW}No dylibs found to be signed!${RESET}"
fi

echo -e "Signing Bundle"
bundlefile=$(find "./$BINARY_SIGNED" -name '*.bundle')
if [ -n "$bundlefile" ]; then
	while read -r bundlename; do
		echo -e "${GREEN}Sign:" "$bundlename" "$RESET"
		codesign --deep --force --verify -vvvv --timestamp --options runtime --entitlements  "$ENTITLEMENTS" --sign "$SIGNCERT" "$bundlename" || { echo -e "${RED}Codesign failure!${RESET}"; exit 1; }
	done <<< "$bundlefile"
else
	echo -e "${YELLOW}No bundles found to be signed!${RESET}"
fi

echo -e "Signing Framework"
frameworkfile=$(find "./$BINARY_SIGNED" -name '*.framework')
if [ -n "$frameworkfile" ]; then
	while read -r frameworkname; do
		echo -e "${GREEN}Sign:" "$frameworkname" "$RESET"
		codesign --deep --force --verify -vvvv --timestamp --options runtime --entitlements  "$ENTITLEMENTS" --sign "$SIGNCERT" "$frameworkname" || { echo -e "${RED}Codesign failure!${RESET}"; exit 1; }
	done <<< "$frameworkfile"
else
	echo -e "${YELLOW}No frameworks found to be signed!${RESET}"
fi

echo -e "Signing the entire app..."
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements  "$ENTITLEMENTS" --sign "$SIGNCERT" "$BINARY_SIGNED" -i "$BUNDLE_ID"

echo -e "Verifications...."
codesign --verify --deep -vvvv --strict "$BINARY_SIGNED" || { echo -e "${RED}Codesigning verification failure!${RESET}"; exit 1; }

echo -e "${GREEN}Signing verified${RESET}"

echo -e "Zipping..."
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$BINARY_SIGNED" "$ZIP_NAME" || { echo -e "${RED}Zipping failed!${RESET}"; exit 1; }

echo -e "Sending for notarization..."

if xcrun altool --notarize-app --asc-provider "$PROVIDERSHORTNAME"  --primary-bundle-id "$BUNDLE_ID" --username "$APPLE_ID" --password "@keychain:${KEYCHAIN_ITEM_ID}" --file "$ZIP_NAME"; then
	echo -e "${GREEN}Success! Your app is being notarized.${RESET}"
	echo "Go grab some coffee and check back later with command xcrun altool --username \"${APPLE_ID}\" --password \"@keychain:${KEYCHAIN_ITEM_ID}\" --notarization-info <replace this with the request uuid that appears above>"
	exit 0
else
	echo -e "${RED}Failed to send the ZIP to notarization services... Is your credential correct, and have you signed all the contracts at App Store Connect first?${RESET}"
	exit 1
fi
