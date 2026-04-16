@echo off
TITLE Development Environment - Khatmah (Skoon)

echo ========================================================
echo        Khatmah (Skoon) Portable Development Setup
echo              Created specially for Yousf
echo ========================================================

:: Set absolute paths dynamically based on where this folder is located
set "PROJECT_DIR=%~dp0"
set "FLUTTER_SDK_PATH=%PROJECT_DIR%devtools\flutter"
set "ANDROID_SDK_PATH=%PROJECT_DIR%devtools\android-sdk"

:: Remove trailing slash if present
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

:: Set environment variables
set "ANDROID_HOME=%ANDROID_SDK_PATH%"
set "ANDROID_SDK_ROOT=%ANDROID_SDK_PATH%"
set "PATH=%FLUTTER_SDK_PATH%\bin;%ANDROID_SDK_PATH%\platform-tools;%PATH%"

echo.
echo [OK] Set ANDROID_HOME to: %ANDROID_HOME%
echo [OK] Set Flutter PATH to: %FLUTTER_SDK_PATH%\bin
echo.

:: Check if Flutter is working
echo Checking Flutter version...
call flutter --version
echo.

echo Developer Environment is ready!
echo You can now run commands like:
echo   - flutter pub get
echo   - flutter run
echo   - flutter build apk
echo.

:: Open a new prompt that stays open and keeps these variables active
cmd.exe /k
