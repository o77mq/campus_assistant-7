# One-shot setup: copies the app code into the Flutter project, patches the Android files, runs pub get and flutter run.
param([string]$Target = (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "campus_assistant77"))
$ErrorActionPreference = "Stop"
$src = $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { $env:Path += ";C:\flutter\bin" }

if (-not (Test-Path $Target)) { New-Item -ItemType Directory $Target | Out-Null }
if (-not (Test-Path (Join-Path $Target "android"))) {
    Push-Location $Target
    flutter create --org com.campus --project-name campus_assistant --platforms=android .
    Pop-Location
}

Write-Host "[1/4] Copying app code..."
if (Test-Path "$Target\lib") { Remove-Item "$Target\lib" -Recurse -Force }
Copy-Item "$src\lib" "$Target\lib" -Recurse
Copy-Item "$src\pubspec.yaml" "$Target\pubspec.yaml" -Force
if (Test-Path "$Target\test") { Remove-Item "$Target\test" -Recurse -Force }

$utf8 = New-Object System.Text.UTF8Encoding $false
$desugar = 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")'

Write-Host "[2/4] Patching Gradle..."
$kts = Join-Path $Target "android\app\build.gradle.kts"
if (Test-Path $kts) {
    $t = Get-Content $kts -Raw
    if ($t -notmatch "isCoreLibraryDesugaringEnabled") {
        $t = $t -replace "compileOptions\s*\{", "compileOptions {`n        isCoreLibraryDesugaringEnabled = true"
        $t = $t -replace "VERSION_1[0-9]", "VERSION_17"
        $t = $t -replace "minSdk\s*=\s*flutter\.minSdkVersion", "minSdk = 24"
        if ($t -match "(?m)^dependencies\s*\{") {
            $t = $t -replace "(?m)^dependencies\s*\{", "dependencies {`n    $desugar"
        } else {
            $t += "`ndependencies {`n    $desugar`n}`n"
        }
        [System.IO.File]::WriteAllText($kts, $t, $utf8)
    }
} else {
    Write-Warning "build.gradle.kts not found - Gradle was not patched."
}

Write-Host "[3/4] Patching AndroidManifest..."
$man = Join-Path $Target "android\app\src\main\AndroidManifest.xml"
$m = Get-Content $man -Raw
if ($m -notmatch "ScheduledNotificationReceiver") {
    $perm = @"
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>

"@
    $recv = @"
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>

"@
    $m = $m -replace "<application", ($perm + "    <application")
    $m = $m -replace "</application>", ($recv + "    </application>")
    [System.IO.File]::WriteAllText($man, $m, $utf8)
}

Write-Host "[4/4] flutter pub get + run..."
Push-Location $Target
flutter pub get
flutter run
Pop-Location
