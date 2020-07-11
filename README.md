# notarization-scripts
Shell scripts to send your App to the notarization service provided by Apple.  
Optimized for Unity games, but should be able to use it for other apps.

# Disclaimer

These scripts are what I used to notarize my Unity app and just decided for anybody else to use.  
Although these scripts do have some the protections against potential damages, **it is never complete.**  
Hence, **please double- and triple- check the values** before running ANY of those scripts!!!!

# Prerequisites

* Mac that can run macOS Catalina (10.15) or later.
* macOS 10.15 or later.
* Xcode 11.0
* An internet connection
* Apple ID
* Apple Developer Account, and
* Paid Apple Developer membership
* Have agreed to all the contract at App Store Connect, and all lamps are green in the 'Contracts' section.
* Installed [`trash`](https://hasseg.org/trash/) command, which you can obtain through homebrew.

# Before using these scripts...

Make sure you have those:
* Your unsigned app
* An .entitlements file. It's strongly suggested to make it with Xcode - creating one from text editor is known to cause issues.

# Usage

1. First, edit the `config.sh` file and fill all the variables but `PROVIDERSHORTNAME`.  
  Set the variables according to the comments. Description below.  
  `PROVIDERSHORTNAME` can be left blank if unknown.  
1. Run `store_credential.sh`.  
  This will trigger a keychain access command so that you can provide your password securely.  
  **This will also give you `$PROVIDERSHORTNAME`. Save it!**
1. Edit `config.sh` file again to include `PROVIDERSHORTNAME`.
1. Run `sign_and_notarize.sh`.  
  This will sign your app including the library it contains.
1. Finally, run `stapling.sh`.  
  This will staple the app and verify its integrity.  
  You can now find your app in `stapled_product` directory.

# Descriptions for available variables

## MUST set

### BINARY_RAW

This is your app to sign, including `.app` extension. This will be left untouched, but will be copied as `$BINARY_SIGNED` (described below.)

**Relative path**, or even, **the app that exist in the same directory as the scripts**, is strongly recommended to prevent unwanted deletion of the files.

### BINARY_SIGNED

What filename do you want for the signed app? Include `.app` extension.

### BUNDLE_ID
Bundle ID for your app. You've set this when you built your app.  
The initial value is intentionally left invalid (contains `_`!)

### ENTITLEMENTS
Path for your entitlements file. Used to sign your binary as well as included libraries.

### APPLE_ID
Your apple id (most of the time, the email address.)  
If you have created an extra apple ID for notarization purposes, which is recommended, use that instead.

### SIGNCERT
The name of your **Developer ID Application certificate. NOT the app store one!**  
If unknown, search for it in the Keychain Access app.  
It probably starts with "Developer ID Application:" without quotes, so try searching with it.  
It should also contain your provider short name, which will be needed below.

### PROVIDERSHORTNAME
Short name for the provider (probably an alphanumeric string.)  
Don't worry if you don't know when you first edit the configuration. You get this when you run store_credential.sh.   
If you forget it, you can run `xcrun altool --list-providers -u $APPLE_ID -p "@keychain:${KEYCHAIN_ITEM_ID}".`

## CAN set
### KEYCHAIN_ITEM_ID="AC_PASSWORD"
You can change this, but you don't really need to. This is just a key used to save your password in your keychain.  

### ZIP_NAME="send_for_notarization.zip"
No need to change it, but you CAN change it to make it more comprehensible. It appears in the result in the notarizatino report.

# Reference

* [How to notarize a Unity build for macOs 10.15 Catalina](https://gist.github.com/dpid/270bdb6c1011fe07211edf431b2d0fe4) - A complete guide for notarizations by dpid.
* [Delivering Unity macOS build to Steam and AppStore](https://yemi.me/2020/02/17/en/submit-unity-macos-build-to-steam-appstore/)

