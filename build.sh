#!/bin/bash
set -e

APP_NAME="Rat"
BUNDLE="${APP_NAME}.app"

mkdir -p "${BUNDLE}/Contents/MacOS"
mkdir -p "${BUNDLE}/Contents/Resources"
cp Rat/Info.plist "${BUNDLE}/Contents/"
cp -R Rat/Resources/. "${BUNDLE}/Contents/Resources/"

swiftc \
    -o "${BUNDLE}/Contents/MacOS/${APP_NAME}" \
    -framework AppKit \
    -framework QuartzCore \
    -target arm64-apple-macos14.0 \
    $(find Rat -name "*.swift")

echo "Built ${BUNDLE} successfully."
