# env.ps1
$ProjectRoot = "C:\Users\yusf2000.runnervmqpruh\.gemini\antigravity\scratch"
$env:JAVA_HOME = "$ProjectRoot\devtools\jdk"
$env:ANDROID_HOME = "$ProjectRoot\devtools\android-sdk"
$env:PATH = "$ProjectRoot\devtools\flutter\bin;$ProjectRoot\devtools\android-sdk\platform-tools;$ProjectRoot\devtools\jdk\bin;" + $env:PATH

if ($args.Count -gt 0) {
    & $args[0] $args[1..($args.Count-1)]
} else {
    echo "Environment set. Provide a command to run."
}
