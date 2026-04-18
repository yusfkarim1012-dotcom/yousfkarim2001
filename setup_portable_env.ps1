# setup_portable_env.ps1
# This script automatically downloads and configures the development environment for the Khatmah project.

$ErrorActionPreference = "Stop"

$ProjectRoot = Get-Location
$DevToolsDir = Join-Path $ProjectRoot "devtools"
$FlutterDir = Join-Path $DevToolsDir "flutter"
$AndroidSdkDir = Join-Path $DevToolsDir "android-sdk"
$JdkDir = Join-Path $DevToolsDir "jdk"

echo "--------------------------------------------------------"
echo "   Khatmah (Khatmah) Environment Bootstrap Script"
echo "--------------------------------------------------------"

# 1. Create directory structure
if (!(Test-Path $DevToolsDir)) {
    New-Item -ItemType Directory -Path $DevToolsDir | Out-Null
    echo "[OK] Created devtools directory."
}

# 2. Download/Setup JDK 17
if (!(Test-Path $JdkDir)) {
    echo "[...] Downloading Portable JDK 17..."
    $JdkZip = Join-Path $DevToolsDir "jdk.zip"
    Invoke-WebRequest -Uri "https://aka.ms/download-jdk/microsoft-jdk-17-windows-x64.zip" -OutFile $JdkZip
    
    echo "[...] Extracting JDK..."
    # Using tar for better performance and reliability
    $TempDir = Join-Path $DevToolsDir "jdk_temp"
    New-Item -ItemType Directory -Path $TempDir | Out-Null
    tar -xf $JdkZip -C $TempDir
    
    $ExtractedFolder = Get-ChildItem -Path $TempDir -Directory | Select-Object -First 1
    Move-Item -Path $ExtractedFolder.FullName -Destination $JdkDir
    
    Remove-Item $JdkZip -Force
    Remove-Item $TempDir -Force -Recurse
    echo "[OK] JDK 17 setup complete."
} else {
    echo "[SKIP] JDK already exists."
}

# Set JAVA_HOME for this session
$env:JAVA_HOME = $JdkDir

# 3. Setup Flutter SDK
if (!(Test-Path $FlutterDir)) {
    echo "[...] Cloning Flutter SDK (Version 3.41.7)..."
    git clone -c core.longpaths=true -b 3.41.7 https://github.com/flutter/flutter.git $FlutterDir --depth 1
    echo "[OK] Flutter SDK setup complete."
} else {
    echo "[SKIP] Flutter SDK already exists."
}

# 4. Setup Android SDK (Minimum)
if (!(Test-Path $AndroidSdkDir)) {
    echo "[...] Downloading Android Command Line Tools..."
    New-Item -ItemType Directory -Path $AndroidSdkDir | Out-Null
    $CmdLineZip = Join-Path $DevToolsDir "cmdline-tools.zip"
    Invoke-WebRequest -Uri "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip" -OutFile $CmdLineZip
    
    echo "[...] Extracting Command Line Tools..."
    $ToolsDest = Join-Path $AndroidSdkDir "cmdline-tools"
    New-Item -ItemType Directory -Path $ToolsDest | Out-Null
    tar -xf $CmdLineZip -C $ToolsDest
    
    # Move 'cmdline-tools' content to 'cmdline-tools/latest' as required by modern sdkmanager
    $LatestDir = Join-Path $ToolsDest "latest"
    Move-Item -Path (Join-Path $ToolsDest "cmdline-tools") -Destination $LatestDir
    
    Remove-Item $CmdLineZip -Force
    
    echo "[...] Installing Android SDK components (Platform 35, Build-Tools 35)..."
    $SdkManager = Join-Path $LatestDir "bin\sdkmanager.bat"
    
    # Accept licenses automatically
    echo "y" | & $SdkManager --sdk_root=$AndroidSdkDir "platforms;android-35" "build-tools;35.0.0" "platform-tools"
    
    echo "[OK] Android SDK minimum components setup complete."
} else {
    echo "[SKIP] Android SDK already exists."
}

# 5. Finalize and Verify
echo "--------------------------------------------------------"
echo "[...] Finalizing environment setup..."
$env:PATH = "$FlutterDir\bin;$AndroidSdkDir\platform-tools;$JdkDir\bin;" + $env:PATH
$env:ANDROID_HOME = $AndroidSdkDir

echo "[...] Running flutter doctor to verify..."
flutter doctor

echo "--------------------------------------------------------"
echo "   All DONE! You can now use 'yousf.bat' to start work."
echo "--------------------------------------------------------"
