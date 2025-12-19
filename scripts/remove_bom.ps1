<#
Remove UTF-8 BOM from build.gradle files in pub cache (or a specific file).

Usage (project root):
  powershell -ExecutionPolicy Bypass -File .\scripts\remove_bom.ps1

This script scans the user's pub cache under hosted/pub.dev for folders named
like `flutter_qiblah*` and removes a UTF-8 BOM from their `android/build.gradle`
if present. It creates a backup `<file>.nobom.bak` before modifying.
#>
try {
    $cache = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'
    if (-not (Test-Path $cache)) { Write-Error "Pub cache path not found: $cache"; exit 2 }

    $plugins = Get-ChildItem -Path $cache -Directory | Where-Object { $_.Name -like 'flutter_qiblah*' }
    if ($plugins.Count -eq 0) { Write-Error 'No flutter_qiblah plugin folders found in pub cache'; exit 3 }

    foreach ($p in $plugins) {
        $file = Join-Path $p.FullName 'android\build.gradle'
        if (-not (Test-Path $file)) { Write-Output "No build.gradle at $file"; continue }

        $bytes = [System.IO.File]::ReadAllBytes($file)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $bak = $file + '.nobom.bak'
            if (-not (Test-Path $bak)) { Copy-Item -Path $file -Destination $bak; Write-Output "Backup created: $bak" }
            $newBytes = $bytes[3..($bytes.Length - 1)]
            [System.IO.File]::WriteAllBytes($file, $newBytes)
            Write-Output "Removed BOM from: $file"
        } else {
            Write-Output "No BOM present in: $file"
        }
    }
    exit 0
} catch {
    Write-Error "Unhandled error: $_"
    exit 99
}
