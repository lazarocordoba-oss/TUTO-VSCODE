<#
.SYNOPSIS
    Configura el equipo como servidor NTP (servicio W32Time) en Windows 11.

.DESCRIPTION
    1. HKLM\...\W32Time\Config                      AnnounceFlags = 5 (antes 0xA)
    2. HKLM\...\W32Time\TimeProviders\NtpServer     Enabled       = 1
    3. Servicio w32time en arranque automatico
    4. Reinicia el servicio (net stop / net start)
    5. Muestra el estado final

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\configurar-ntp.ps1
#>

$ErrorActionPreference = 'Stop'

# --- Auto-elevacion a administrador ---
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Solicitando permisos de administrador...' -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$configKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config'
$ntpKey    = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer'

try {
    Write-Host "`n[1/5] AnnounceFlags -> 5" -ForegroundColor Cyan
    $old = (Get-ItemProperty -Path $configKey -Name AnnounceFlags -ErrorAction SilentlyContinue).AnnounceFlags
    Set-ItemProperty -Path $configKey -Name AnnounceFlags -Value 5 -Type DWord
    Write-Host ("      antes: 0x{0:X}  ahora: 5" -f $old)

    Write-Host "`n[2/5] NtpServer\Enabled -> 1" -ForegroundColor Cyan
    if (-not (Test-Path $ntpKey)) { New-Item -Path $ntpKey -Force | Out-Null }
    $old = (Get-ItemProperty -Path $ntpKey -Name Enabled -ErrorAction SilentlyContinue).Enabled
    Set-ItemProperty -Path $ntpKey -Name Enabled -Value 1 -Type DWord
    Write-Host "      antes: $old  ahora: 1"

    Write-Host "`n[3/5] Arranque automatico del servicio" -ForegroundColor Cyan
    Set-Service -Name w32time -StartupType Automatic

    Write-Host "`n[4/5] Reiniciando servicio w32time" -ForegroundColor Cyan
    Stop-Service -Name w32time -Force -ErrorAction SilentlyContinue
    Start-Service -Name w32time

    Write-Host "`n[5/5] Comprobacion" -ForegroundColor Cyan
    Get-Service w32time | Format-Table Name, Status, StartType -AutoSize
    & sc.exe qc w32time
    & w32tm /query /configuration | Select-String 'AnnounceFlags|NtpServer|Enabled'

    Write-Host "`n===== Configuracion NTP completada correctamente =====" -ForegroundColor Green
}
catch {
    Write-Host "`n***** ERROR: $($_.Exception.Message) *****" -ForegroundColor Red
    Read-Host 'Pulsa Enter para salir'
    exit 1
}

Read-Host 'Pulsa Enter para salir'
