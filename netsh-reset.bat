@echo off
setlocal

:: === Configuration ===
set "LOGDIR=%USERPROFILE%\Desktop\NetResetLogs"
set "LOGFILE=%LOGDIR%\reset_%date:~-10,2%-%date:~-7,2%-%date:~-4,4%_%time:~0,2%-%time:~3,2%.log"

md "%LOGDIR%" 2>nul
echo Reset run on %date% %time%>>"%LOGFILE%"

:: === Require Admin ===
net session >nul 2>&1 || (
  echo ERROR: Admin rights required. >>"%LOGFILE%"
  echo Run as administrator.
  pause
  exit /b 1
)

:: === Core Reset ===
echo Resetting Winsock...>>"%LOGFILE%" & netsh winsock reset >>"%LOGFILE%" 2>&1
echo Resetting IPv4/IPv6...>>"%LOGFILE%" & (
  netsh int ip reset >>"%LOGFILE%" 2>&1
  netsh int ipv6 reset >>"%LOGFILE%" 2>&1
)
echo Flushing DNS & renewing IP...>>"%LOGFILE%" & (
  ipconfig /flushdns >>"%LOGFILE%" 2>&1
  ipconfig /release >>"%LOGFILE%" 2>&1
  ipconfig /renew >>"%LOGFILE%" 2>&1
)
echo Clearing ARP & NetBIOS caches...>>"%LOGFILE%" & (
  arp -d * >>"%LOGFILE%" 2>&1
  nbtstat -R >>"%LOGFILE%" 2>&1
)

:: === Firewall & Proxy (optional) ===
netsh advfirewall reset >>"%LOGFILE%" 2>&1
netsh winhttp reset proxy >>"%LOGFILE%" 2>&1

:: === Final Report ===
echo >>"%LOGFILE%" & ipconfig /all >>"%LOGFILE%" 2>&1

echo.
echo Network reset complete. Log: %LOGFILE%
echo.
choice /C YN /M "Restart now? (Y/N)" >nul
if errorlevel 2 goto no_reboot
echo Restarting... & timeout /t 5 >nul & shutdown /r /t 0
goto end

:no_reboot
echo Please reboot later to finalize changes.

:end
pause
