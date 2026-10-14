#!/usr/bin/env bash
# Script to build size-optimized IPA for iOS
echo "Building size-optimized iOS Release IPA..."
flutter build ipa --release --obfuscate --split-debug-info=build/app/outputs/symbols
echo "Done! IPA is saved in build/ios/archive/ or build/ios/ipa/"
