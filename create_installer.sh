#!/bin/bash

# Configuration
APP_NAME="Aether"
INSTALLER_NAME="${APP_NAME}_Installer"
VOL_NAME="${APP_NAME} Installer"
BG_IMAGE="Installer/dmg_background_generated.png" # Updated path
SOURCE_FOLDER="dmg-source"

# Ensure create-dmg exists
if [ ! -d "create-dmg-repo" ]; then
    echo "Error: create-dmg-repo not found. Please clone it."
    exit 1
fi

# Clean previous build
rm -f "${INSTALLER_NAME}.dmg"
rm -rf "$SOURCE_FOLDER"
mkdir "$SOURCE_FOLDER"

# Check if App exists
if [ ! -d "${APP_NAME}.app" ]; then
    echo "Error: ${APP_NAME}.app not found. Run ./build_app.sh first."
    exit 1
fi

# Prepare Source
cp -r "${APP_NAME}.app" "$SOURCE_FOLDER/"

# Run create-dmg
./create-dmg-repo/create-dmg \
  --volname "$VOL_NAME" \
  --background "$BG_IMAGE" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 80 \
  --icon "${APP_NAME}.app" 150 150 \
  --app-drop-link 450 150 \
  "${INSTALLER_NAME}.dmg" \
  "$SOURCE_FOLDER/"
