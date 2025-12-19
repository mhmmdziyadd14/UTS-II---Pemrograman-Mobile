<#
Patch flutter_qiblah plugin in pub cache by adding Android namespace.

This script will:
- locate the latest `flutter_qiblah-*` folder in the pub cache
- read android/src/main/AndroidManifest.xml to get the package="..." value
- backup android/build.gradle to android/build.gradle.bak
- insert `namespace '<package>'` after the `android {` line if missing

Run from PowerShell (no admin required for file edits in user's AppData):
  powershell -ExecutionPolicy Bypass -File .\scripts\patch_flutter_qiblah.ps1

If you prefer manual editing, open the manifest to read the package value and add
`namespace 'that.package.name'` inside the `android {` block in the plugin's build.gradle.
#>
try {
    $cache = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'
    if (-not (Test-Path $cache)) {
        Write-Error "Pub cache path not found: $cache"
        exit 2
    }

    $dirs = Get-ChildItem -Path $cache -Directory | Where-Object { $_.Name -like 'flutter_qiblah*' } | Sort-Object LastWriteTime -Descending
    if ($dirs.Count -eq 0) {
        Write-Error 'flutter_qiblah plugin not found in pub cache under hosted/pub.dev'
        exit 3
    }

    $plugin = $dirs[0].FullName
    Write-Output "Using plugin folder: $plugin"

    $manifest = Join-Path $plugin 'android\src\main\AndroidManifest.xml'
    if (-not (Test-Path $manifest)) { Write-Error "AndroidManifest.xml not found at $manifest"; exit 4 }
    $manifestContent = Get-Content $manifest -Raw

    $pkg = $null
    if ($manifestContent -match 'package\s*=\s*"([^"]+)"') { $pkg = $matches[1] }
    if (-not $pkg) { Write-Error 'Could not find package="..." attribute in AndroidManifest.xml'; exit 5 }
    Write-Output "Detected plugin package: $pkg"

    $buildGradle = Join-Path $plugin 'android\build.gradle'
    if (-not (Test-Path $buildGradle)) { Write-Error "build.gradle not found at $buildGradle"; exit 6 }

    $bak = $buildGradle + '.bak'
    if (-not (Test-Path $bak)) { Copy-Item -Path $buildGradle -Destination $bak; Write-Output "Backup created: $bak" }

    $grad = Get-Content $buildGradle -Raw

    if ($grad -like "*namespace '$pkg'*" -or $grad -like "*namespace `"$pkg`"*") {
        Write-Output "Namespace already present for package $pkg. No changes made."
        exit 0
    }

    $pattern = 'android\s*\{'
    if ($grad -match $pattern) {
        $replacement = "android {`n    namespace '$pkg'"
        $new = $grad -replace $pattern, $replacement
        Set-Content -Path $buildGradle -Value $new -Encoding UTF8
        Write-Output "Patched build.gradle with namespace '$pkg'"
        exit 0
    } else {
        Write-Error "Could not find an android { block in build.gradle to patch."
        exit 7
    }
} catch {
    Write-Error "Unhandled error: $_"
    exit 99
}
