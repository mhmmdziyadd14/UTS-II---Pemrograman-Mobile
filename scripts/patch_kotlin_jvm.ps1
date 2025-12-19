<#
Ensure Kotlin JVM target compatibility for flutter_qiblah plugin in pub cache.

This script will:
- locate the latest `flutter_qiblah-*` folder in the pub cache
- create a backup of android/build.gradle if not already present
- append a KotlinCompile configuration block to set `kotlinOptions.jvmTarget = "17"`

Run:
  powershell -ExecutionPolicy Bypass -File .\scripts\patch_kotlin_jvm.ps1
#>
try {
    $cache = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'
    if (-not (Test-Path $cache)) { Write-Error "Pub cache path not found: $cache"; exit 2 }

    $dirs = Get-ChildItem -Path $cache -Directory | Where-Object { $_.Name -like 'flutter_qiblah*' } | Sort-Object LastWriteTime -Descending
    if ($dirs.Count -eq 0) { Write-Error 'flutter_qiblah plugin not found in pub cache under hosted/pub.dev'; exit 3 }

    $plugin = $dirs[0].FullName
    Write-Output "Using plugin folder: $plugin"

    $buildGradle = Join-Path $plugin 'android\build.gradle'
    if (-not (Test-Path $buildGradle)) { Write-Error "build.gradle not found at $buildGradle"; exit 4 }

    $bak = $buildGradle + '.jvm.bak'
    if (-not (Test-Path $bak)) { Copy-Item -Path $buildGradle -Destination $bak; Write-Output "Backup created: $bak" }

    $content = Get-Content $buildGradle -Raw

    $block = "`n// Added by patch_kotlin_jvm.ps1 to align Kotlin JVM target`nimport org.jetbrains.kotlin.gradle.tasks.KotlinCompile`n`ntasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {`n    kotlinOptions {`n        jvmTarget = '17'`n    }`n}`n"

    if ($content -match "jvmTarget\s*=\s*'17'" -or $content -match 'jvmTarget\s*=\s*"17"') {
        Write-Output 'kotlinOptions jvmTarget already set to 17 in build.gradle. No changes.'
        exit 0
    }

    Add-Content -Path $buildGradle -Value $block -Encoding UTF8
    Write-Output "Appended kotlinOptions JVM target block to: $buildGradle"
    exit 0
} catch {
    Write-Error "Unhandled error: $_"
    exit 99
}
