@echo off
REM ============================================================
REM  Configura el equipo como servidor NTP (servicio W32Time)
REM  - AnnounceFlags = 5  (antes 0xA)
REM  - NtpServer\Enabled = 1
REM  - Reinicia w32time y lo deja en arranque automatico
REM  Doble clic: pide permisos de administrador automaticamente.
REM ============================================================

REM --- Auto-elevacion a administrador ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando permisos de administrador...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo [1/5] AnnounceFlags -> 5
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v AnnounceFlags /t REG_DWORD /d 5 /f
if %errorlevel% neq 0 goto :error

echo.
echo [2/5] NtpServer\Enabled -> 1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" /v Enabled /t REG_DWORD /d 1 /f
if %errorlevel% neq 0 goto :error

echo.
echo [3/5] Arranque automatico del servicio
sc config w32time start= auto
if %errorlevel% neq 0 goto :error

echo.
echo [4/5] Reiniciando servicio w32time
net stop w32time
net start w32time
if %errorlevel% neq 0 goto :error

echo.
echo [5/5] Comprobacion
sc qc w32time
reg query "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v AnnounceFlags
reg query "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" /v Enabled

echo.
echo ===== Configuracion NTP completada correctamente =====
pause
exit /b 0

:error
echo.
echo ***** ERROR: el paso anterior ha fallado (codigo %errorlevel%) *****
pause
exit /b 1
