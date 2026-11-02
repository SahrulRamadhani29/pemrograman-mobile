$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$campusPhp = $env:CAMPUS_PHP
if (-not $campusPhp) {
    $candidate = 'C:\laragon\bin\php\php-8.5.5-Win32-vs17-x64\php.exe'
    $campusPhp = if (Test-Path -LiteralPath $candidate) { $candidate } else { (Get-Command php).Source }
}
if (-not (Test-Path -LiteralPath 'assets\dev-ca.pem')) {
    python scripts/setup_local.py
    if ($LASTEXITCODE -ne 0) { throw 'Persiapan HTTPS gagal.' }
}
if (-not (Test-Path -LiteralPath 'android\app\google-services.json')) {
    throw 'Simpan google-services.json dari Firebase ke android/app terlebih dahulu.'
}
if (-not (Get-NetTCPConnection -LocalPort 8006 -State Listen -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $campusPhp -ArgumentList @('artisan','serve','--host=127.0.0.1','--port=8006') -WorkingDirectory (Join-Path $PSScriptRoot 'backend') -WindowStyle Hidden -RedirectStandardOutput (Join-Path $PSScriptRoot 'backend\storage\logs\serve-out.log') -RedirectStandardError (Join-Path $PSScriptRoot 'backend\storage\logs\serve-error.log')
}
if (-not (Get-NetTCPConnection -LocalPort 8446 -State Listen -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath (Get-Command python).Source -ArgumentList @('scripts/https_proxy.py') -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $PSScriptRoot 'backend\storage\logs\https-out.log') -RedirectStandardError (Join-Path $PSScriptRoot 'backend\storage\logs\https-error.log')
}
adb -s 33a40574 reverse tcp:8446 tcp:8446
if ($LASTEXITCODE -ne 0) { throw 'Vivo belum terhubung. Periksa kabel dan USB debugging.' }
flutter run -d 33a40574
