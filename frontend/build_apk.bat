@echo off
title CleanPixel AI - Full Release Build Pipeline
echo ========================================================
echo        CLEANPIXEL AI - PRODUCTION BUILD PIPELINE
echo ========================================================

cd /d "%~dp0"

echo [1/4] Cleaning previous builds...
call flutter clean
call flutter pub get

echo.
echo [2/4] Building Official Signed Universal Release APK...
call flutter build apk --release

echo.
echo [3/4] Building Official Signed Google Play Store Bundle (AAB)...
call flutter build appbundle --release

echo.
echo [4/4] Distributing artifacts to Desktop and Downloads...
powershell -Command "Copy-Item 'build\app\outputs\flutter-apk\app-release.apk' -Destination '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.apk' -Force -ErrorAction SilentlyContinue"
powershell -Command "Copy-Item 'build\app\outputs\bundle\release\app-release.aab' -Destination '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.aab' -Force -ErrorAction SilentlyContinue"
powershell -Command "if (Test-Path '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.zip') { Remove-Item '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.zip' }; Compress-Archive -Path '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.apk' -DestinationPath '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.zip'"
powershell -Command "Copy-Item '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.apk' -Destination '$env:USERPROFILE\Downloads\CleanPixel_AI.apk' -Force -ErrorAction SilentlyContinue"
powershell -Command "Copy-Item '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.zip' -Destination '$env:USERPROFILE\Downloads\CleanPixel_AI.zip' -Force -ErrorAction SilentlyContinue"
powershell -Command "Copy-Item '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.apk' -Destination '..\ui\CleanPixel_AI.apk' -Force -ErrorAction SilentlyContinue"
powershell -Command "Copy-Item '$env:USERPROFILE\OneDrive\Desktop\CleanPixel_AI.zip' -Destination '..\ui\CleanPixel_AI.zip' -Force -ErrorAction SilentlyContinue"

echo.
echo ========================================================
echo   BUILD COMPLETE! Official Signed APK & AAB Ready!
echo   - Direct APK: Desktop\CleanPixel_AI.apk
echo   - Play Store AAB: Desktop\CleanPixel_AI.aab
echo   - Sharing ZIP: Desktop\CleanPixel_AI.zip
echo ========================================================
pause
