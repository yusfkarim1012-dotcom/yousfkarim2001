# run_flutter.ps1
param (
    [string]$Command
)

$ProjectRoot = Get-Location
$DevToolsDir = Join-Path $ProjectRoot "devtools"
$FlutterBin = Join-Path $DevToolsDir "flutter\bin"
$AndroidSdkDir = Join-Path $DevToolsDir "android-sdk"
$JdkDir = Join-Path $DevToolsDir "jdk"

$env:JAVA_HOME = $JdkDir
$env:ANDROID_HOME = $AndroidSdkDir
$env:PATH = "$FlutterBin;$AndroidSdkDir\platform-tools;$JdkDir\bin;" + $env:PATH

Invoke-Expression "flutter $Command"
