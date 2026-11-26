# Installs eye (https://github.com/dylankyc/eye) on Windows x86_64.
#
#   irm https://raw.githubusercontent.com/dylankyc/eye/main/install.ps1 | iex
#
# Environment: EYE_VERSION (default: latest), EYE_INSTALL_DIR (default: %LOCALAPPDATA%\Programs\eye)
$ErrorActionPreference = 'Stop'

$repo = 'dylankyc/eye'
$target = 'x86_64-pc-windows-gnu'
$asset = "eye-$target.zip"
$version = if ($env:EYE_VERSION) { $env:EYE_VERSION } else { 'latest' }
$installDir = if ($env:EYE_INSTALL_DIR) { $env:EYE_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\eye' }
$base = if ($version -eq 'latest') { "https://github.com/$repo/releases/latest/download" } else { "https://github.com/$repo/releases/download/$version" }

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("eye-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    Write-Host "Downloading $asset ($version)..."
    $zip = Join-Path $tmp $asset
    $sums = Join-Path $tmp 'SHA256SUMS'
    Invoke-WebRequest -UseBasicParsing "$base/$asset" -OutFile $zip
    Invoke-WebRequest -UseBasicParsing "$base/SHA256SUMS" -OutFile $sums

    $line = Get-Content $sums | Where-Object { $_ -match " $([regex]::Escape($asset))$" } | Select-Object -First 1
    if (-not $line) { throw "no checksum for $asset" }
    $expected = ($line -split ' ')[0].ToLower()
    $actual = (Get-FileHash -Algorithm SHA256 $zip).Hash.ToLower()
    if ($expected -ne $actual) { throw "checksum mismatch for $asset" }

    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    Copy-Item (Join-Path $tmp "eye-$target\eye.exe") (Join-Path $installDir 'eye.exe') -Force

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $installDir) {
        [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $installDir), 'User')
        Write-Host "Added $installDir to your user PATH (open a new terminal to use it)."
    }
    Write-Host "Installed eye to $installDir\eye.exe"
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
