# Antigravity & AI Agent Guide - Khatmah (Skoon) Project

> **IMPORTANT NOTICE FOR ANY AI AGENT / LLM:** 
> Read this document completely BEFORE making any modifications to the project or running any build commands. This ensures you do not break the environment setup.

## 1. Project Context
* **App Name:** Khatmah / Skoon
* **Type:** Flutter Android Application
* **User Context:** The user primarily builds this app for Android (APK for testing, AAB for Google Play Store upload). The user prefers stability and no unnecessary code changes unless explicitly requested.

## 2. Environment Variables & Paths (Crucial)
The user's local machine has a specific configuration. If you try to run `flutter build` without these environment variables properly mapped, the build **WILL FAIL** due to read-only paths or missing SDKs.
Before running any `flutter` command, make sure to set up the terminal session with:

* **Flutter Path:** `devtools\flutter\bin` (Inside the project itself)
* **Android SDK:** `devtools\android-sdk` (Inside the project itself)
* **Java:** JDK 17 

**PowerShell Command Prefix Example:**
```powershell
call %~dp0yousf.bat
```

## 3. App Signing & Keystore (Security)
* **DO NOT** commit the Keystore (`*.jks`) or `key.properties` to version control. They are explicitly excluded in `.gitignore`.
* The `key.properties` file points to `storeFile=../yousf.jks`.
* Keystore Alias: `yousf`
* If the user asks for a release build, run the build command natively. Do not regenerate the keystore unless explicitly requested, as losing the original keystore breaks future Google Play updates.

## 4. Build Instructions & Troubleshooting
* **Dependency Issues:** Always run `flutter pub get` after modifying `pubspec.yaml` or if cache is invalidated.
* **Disk Space Problems:** The host machine occasionally gets low on `C:` drive space. If a build fails with `There is not enough space on the disk`, immediately run `flutter clean` and reset the Gradle daemon (`.\gradlew --stop`).
* **Command to Build AAB:** `flutter build appbundle --release`
* **Command to Build APK:** `flutter build apk --release`

## 5. Rules of Engagement
1. Do not indiscriminately upgrade `pubspec.yaml` dependencies unless the build strictly requires it, to avoid breaking changes.
2. The user has `.git` configured locally and connected to a remote `origin`. Push changes using the existing Git Setup when completing a feature.
3. Keep answers clear, explain technical concepts specifically in Kurdish when the user asks.
