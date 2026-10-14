#!/usr/bin/env bash
# Script to build size-optimized split APKs for Android
echo "Building size-optimized Android Release APKs..."
flutter build apk --split-per-abi --release --obfuscate --split-debug-info=build/app/outputs/symbols
echo "Done! APKs are saved in build/app/outputs/flutter-apk/"
