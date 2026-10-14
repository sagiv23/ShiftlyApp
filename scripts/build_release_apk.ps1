# Script to build size-optimized split APKs for Android
Write-Host "Building size-optimized Android Release APKs..." -ForegroundColor Green
flutter build apk --split-per-abi --release --obfuscate --split-debug-info=build/app/outputs/symbols
Write-Host "Done! APKs are saved in build/app/outputs/flutter-apk/" -ForegroundColor Green
