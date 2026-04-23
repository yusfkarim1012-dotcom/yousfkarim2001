@echo off
set "PROJECT_DIR=%~dp0"
set "FLUTTER_SDK_PATH=%PROJECT_DIR%devtools\flutter"
set "ANDROID_SDK_PATH=%PROJECT_DIR%devtools\android-sdk"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "ANDROID_HOME=%ANDROID_SDK_PATH%"
set "ANDROID_SDK_ROOT=%ANDROID_SDK_PATH%"
set "PATH=%FLUTTER_SDK_PATH%\bin;%ANDROID_SDK_PATH%\platform-tools;%PATH%"

flutter build appbundle --release
