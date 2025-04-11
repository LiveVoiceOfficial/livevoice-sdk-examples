#!/bin/bash

set -e

echo "🔄 Cleaning up..."

# Delete folders
rm -rf ./node_modules
rm -rf ./ios/build
rm -rf ./ios/Pods
rm -rf ./ios/Podfile.lock
rm -rf ./android/build
rm -rf ./android/app/build


# Delete yarn.lock and any *.tgz files in top-level, don't fail if they don't exist
rm -f ./yarn.lock || true

echo "✅ Folders and files cleaned."

# Install dependencies
echo "📦 Installing yarn packages..."
yarn install

# Navigate to example/ios and run pod install
echo "📲 Installing CocoaPods in example/ios..."
cd ios
pod install

echo "✅ Done with clear-all!"