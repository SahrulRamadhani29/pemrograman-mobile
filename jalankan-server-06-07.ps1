$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$campusPhp = $env:CAMPUS_PHP
if (-not $campusPhp) {
    $campusPhp = 'C:\laragon\bin\php\php-8.5.5-Win32-vs17-x64\php.exe'
}
if (-not (Test-Path -LiteralPath $campusPhp)) {
    throw 'PHP 8.5 belum ditemukan. Isi variabel CAMPUS_PHP dengan lokasi php.exe.'
}
$campusPython = (Get-Command python -ErrorAction Stop).Source
$campusWeeks = @(
    @{ Folder = 'Minggu-06'; ApiPort = 8006; HttpsPort = 8446 },
    @{ Folder = 'Minggu-07'; ApiPort = 8007; HttpsPort = 8447 }
)
foreach ($campusWeek in $campusWeeks) {
    $campusRoot = Join-Path $PSScriptRoot $campusWeek.Folder
    $campusBackend = Join-Path $campusRoot 'backend'
    if (-not (Test-Path -LiteralPath (Join-Path $campusBackend 'storage\app\private\server-key.pem'))) {
        throw "Sertifikat lokal $($campusWeek.Folder) belum siap. Jalankan scripts/setup_local.py dari folder minggu tersebut."
    }
    if (-not (Get-NetTCPConnection -State Listen -LocalPort $campusWeek.ApiPort -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $campusPhp -ArgumentList @('artisan', 'serve', '--host=127.0.0.1', "--port=$($campusWeek.ApiPort)") -WorkingDirectory $campusBackend -WindowStyle Hidden -RedirectStandardOutput (Join-Path $campusBackend 'storage\logs\serve-out.log') -RedirectStandardError (Join-Path $campusBackend 'storage\logs\serve-error.log')
    }
    if (-not (Get-NetTCPConnection -State Listen -LocalPort $campusWeek.HttpsPort -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $campusPython -ArgumentList @('scripts/https_proxy.py') -WorkingDirectory $campusRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $campusBackend 'storage\logs\https-out.log') -RedirectStandardError (Join-Path $campusBackend 'storage\logs\https-error.log')
    }
    adb -s 33a40574 reverse "tcp:$($campusWeek.HttpsPort)" "tcp:$($campusWeek.HttpsPort)"
    if ($LASTEXITCODE -ne 0) {
        throw 'Vivo belum terhubung. Sambungkan kabel data dan izinkan USB debugging.'
    }
    Write-Host "$($campusWeek.Folder): API $($campusWeek.ApiPort), HTTPS $($campusWeek.HttpsPort)."
}
Write-Host 'Server kedua minggu sudah dijalankan. Buka ikon Campus 06 atau Campus 07 di Vivo.'
