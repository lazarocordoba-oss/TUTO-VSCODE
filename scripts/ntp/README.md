# Configurar servidor NTP en Windows 11 (automatizado)

Automatiza los pasos manuales de `NTP.txt`:

| Paso | Manual | Automatico |
|------|--------|------------|
| 1 | regedit `...\W32Time\Config` → `AnnounceFlags` `a` → `5` | `reg add ... /v AnnounceFlags /d 5` |
| 2 | regedit `...\W32Time\TimeProviders\NtpServer` → `Enabled` `0` → `1` | `reg add ... /v Enabled /d 1` |
| 3 | `net stop w32time` / `net start w32time` | incluido |
| 4 | `sc config w32time start= auto` | incluido |
| 5 | `sc qc w32time` | incluido (comprobacion final) |

## Archivos

- **`configurar-ntp.bat`** – el mas sencillo: **doble clic**. Pide permisos de administrador solo y hace todo.
- **`configurar-ntp.ps1`** – lo mismo en PowerShell, muestra valores antes/despues.
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\configurar-ntp.ps1
  ```
- **`configurar-ntp.reg`** – solo los dos cambios de registro (doble clic → Si). Despues hay que reiniciar el servicio a mano.

## Comprobar que funciona

```cmd
w32tm /query /configuration
w32tm /query /status
```
Desde otro equipo de la red: `w32tm /stripchart /computer:<IP_de_este_equipo> /samples:3`

> Si otros equipos no pueden sincronizar, abre el puerto **UDP 123** en el firewall:
> `netsh advfirewall firewall add rule name="NTP Server" dir=in action=allow protocol=UDP localport=123`
