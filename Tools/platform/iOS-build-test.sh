#!/bin/bash

# Basic sanity check before commit that all the expected targets build and test

# Note: don't include 'arch=' within the destination on macOS builds so it _should_ work for M1 arm based macs as well as Intel

# Stop on error
set -e

ORIGDIR=$PWD
BASEDIR=$(dirname $(realpath "$0"))

pushd .

# Move back up to the QRCode root directory, or else Xcode complains...
cd "${BASEDIR}"/../..

echo ">>>> iOS build and test..."

xcodebuild clean build archive -scheme "ColorPaletteCodable" -destination 'generic/platform=iOS' -quiet
xcodebuild test -scheme "ColorPaletteCodable" -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation)' -quiet

echo "<<<< iOS build and test COMPLETE..."

popd
