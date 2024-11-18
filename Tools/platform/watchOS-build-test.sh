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

echo ">>>> watchOS build and test..."

xcodebuild clean build archive -scheme "ColorPaletteCodable" -destination 'generic/platform=watchOS' -quiet
xcodebuild test -scheme "ColorPaletteCodable" -destination 'platform=watchOS Simulator,name=Apple Watch SE (40mm) (2nd generation)' -quiet

echo "<<<< watchOS build and test COMPLETE..."

popd
