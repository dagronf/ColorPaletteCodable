#!/bin/zsh -e

SCRIPT_DIR=$(realpath $(dirname $0))
echo $SCRIPT_DIR

cd ${SCRIPT_DIR}/../

echo "Build macOS"
xcodebuild -scheme ColorPaletteCodable test -destination "platform=macOS,OS=latest"
echo "... Build macOS complete"
echo
echo "Build iOS ..."
xcodebuild -scheme ColorPaletteCodable test -destination "platform=iOS Simulator,name=iPhone SE,OS=latest"
echo "... Build iOS complete"
echo
echo "Build iPad ..."
xcodebuild -scheme ColorPaletteCodable test -destination "platform=iOS Simulator,name=iPad Air (5th generation),OS=latest"
echo "... Build iPad complete"
echo
echo "Build tvOS ..."
xcodebuild -scheme ColorPaletteCodable test -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd Generation),OS=latest"
echo "... Build tvOS complete"
echo
echo "Build watchOS ..."
xcodebuild -scheme ColorPaletteCodable test -destination "platform=watchOS Simulator,name=Apple Watch SE (40mm) (2nd generation),OS=latest"
echo "... Build watchOS complete"
echo
echo "Build macCatalyst ..."
xcodebuild -scheme ColorPaletteCodable test -destination "platform=macOS,variant=Mac Catalyst,OS=latest"
echo "... Build macCatalyst complete"
echo
echo "Done!"