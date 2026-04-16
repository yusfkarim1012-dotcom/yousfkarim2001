# Antigravity & AI Agent Guide - Khatmah (Skoon) Project

> **IMPORTANT NOTICE FOR ANY AI AGENT / LLM:** 
> Read this document completely BEFORE making any modifications to the project or running any build commands. This ensures you do not break the environment setup.

## 1. Project Context
* **App Name:** Khatmah / Skoon
* **Type:** Flutter Android Application
* **User Context:** The user primarily builds this app for Android (APK for testing, AAB for Google Play Store upload). The user prefers stability and no unnecessary code changes unless explicitly requested.

## 2. Ready-to-Work Checklist (FOR AI AGENT)
Upon opening this project, the AI MUST verify the following and report to the user:
1. **Check for `devtools` folder:** Does it contain the following specific versions?
   * **Flutter SDK:** Version `3.41.7` (Channel: stable)
   * **Android SDK Platforms:** `android-35` (Minimum), `android-34`
   * **Android Build-Tools:** `35.0.0` or higher
2. **Missing SDKs?** If the `devtools` folder or specific versions are missing, the AI MUST run `.\setup_portable_env.ps1` in PowerShell to automatically download and configure the minimum required environment.
3. **Environment Setup:** Run `yousf.bat` to set local paths after setup.
4. **Target SDK:** Ensure `android/app/build.gradle.kts` matches `targetSdk = 35`.
5. **Keystore & Passwords:** Verify if `yousf.jks`, `key.properties`, and `yousf_keystore_passwords.txt` exist. The AI should read the passwords from the text file when building the app.

**Report Status:** "Ready to work (Local SDKs found)" OR "Setting up environment... (Running bootstrap script)".

## 3. Environment Variables & Paths (Crucial)
The user's local machine has a specific configuration. If you try to run `flutter build` without these environment variables properly mapped, the build **WILL FAIL** due to read-only paths or missing SDKs.
Before running any `flutter` command, make sure to set up the terminal session with:

* **Flutter Path:** `devtools\flutter\bin` (Inside the project itself)
* **Android SDK:** `devtools\android-sdk` (Inside the project itself)
* **Java:** JDK 17 

> [!IMPORTANT]
> **Missing `devtools`?** The `devtools` folder (containing Flutter and Android SDKs) is NOT included in this Git repository due to its large size (~12GB). 
> You must download the `devtools` folder separately from the user's private storage and extract it into the project root directory before running any build commands.

**PowerShell Command Prefix Example:**
```powershell
call %~dp0yousf.bat
```

## 3. App Signing & Keystore (Security)
* **DO NOT** commit the Keystore (`*.jks`) or `key.properties` to version control. They are explicitly excluded in `.gitignore`.
* The `key.properties` file points to `storeFile=../yousf.jks`.
* Keystore Alias: `yousf`
* If the user asks for a release build, run the build command natively. Do not regenerate the keystore unless explicitly requested, as losing the original keystore breaks future Google Play updates.

## 4. Build Instructions & Maintenance
* **Environment Readiness:** AI should run `flutter doctor` after setting the paths to confirm the environment is healthy.
* **Dependency Issues:** Always run `flutter pub get` after modifying `pubspec.yaml`.
* **Disk Space Problems:** If a build fails with `There is not enough space on the disk`, the AI should:
    1. Run `flutter clean`.
    2. Run `.\gradlew --stop` in the `android` folder.
    3. If still low, clear `.gradle/caches` in the user's home directory.
* **Build Debugging:** Use `flutter build appbundle --release --verbose` if errors are cryptic.
* **Command to Build AAB:** `flutter build appbundle --release`
* **Command to Build APK:** `flutter build apk --release`

## 5. Rules of Engagement
1. Do not indiscriminately upgrade `pubspec.yaml` dependencies unless the build strictly requires it, to avoid breaking changes.
2. The user has `.git` configured locally and connected to a remote `origin`. Push changes using the existing Git Setup when completing a feature.
3. Keep answers clear, explain technical concepts specifically in Kurdish when the user asks.
