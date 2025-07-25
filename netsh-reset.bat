@echo off
setlocal enabledelayedexpansion
title Network Reset and Troubleshooting Tool

:: Color codes for output
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

:: Create log file with timestamp
set "LOG_FILE=%TEMP%\NetworkReset_%DATE:~-4,4%%DATE:~-10,2%%DATE:~-7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

echo %BLUE%========================================%RESET%
echo %BLUE%  Network Reset and Troubleshooting Tool%RESET%
echo %BLUE%========================================%RESET%
echo.
echo Log file: %LOG_FILE%
echo.

:: Initialize log file
echo Network Reset Log - %DATE% %TIME% > "%LOG_FILE%"
echo ================================================== >> "%LOG_FILE%"

:: Function to log messages
:log
echo %~1 >> "%LOG_FILE%"
goto :eof

:: Check for administrative privileges
call :log "Checking administrative privileges..."
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%ERROR: This script requires administrative privileges.%RESET%
    echo %YELLOW%Please right-click and select "Run as administrator"%RESET%
    call :log "ERROR: Script not running with administrative privileges"
    pause
    exit /b 1
)

echo %GREEN%✓ Administrative privileges confirmed%RESET%
call :log "Administrative privileges confirmed"
echo.

:: Display current network configuration before reset
echo %BLUE%Current Network Configuration:%RESET%
echo %YELLOW%Active Network Adapters:%RESET%
ipconfig | findstr /C:"Ethernet adapter" /C:"Wireless LAN adapter" /C:"IPv4 Address"
echo.

:: Ask user for confirmation
set /p "CONFIRM=Do you want to proceed with network reset? (Y/N): "
if /i "!CONFIRM!" neq "Y" (
    echo %YELLOW%Operation cancelled by user.%RESET%
    call :log "Operation cancelled by user"
    pause
    exit /b 0
)

call :log "User confirmed network reset operation"
echo.

:: Step 1: Reset Winsock and TCP/IP Stack
echo %BLUE%Step 1: Resetting Winsock and TCP/IP Stack...%RESET%
call :log "Starting Winsock and TCP/IP reset"

echo   - Resetting Winsock catalog...
netsh winsock reset >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ Winsock reset successful%RESET%
    call :log "Winsock reset successful"
) else (
    echo     %RED%✗ Winsock reset failed%RESET%
    call :log "ERROR: Winsock reset failed"
)

echo   - Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ TCP/IP stack reset successful%RESET%
    call :log "TCP/IP stack reset successful"
) else (
    echo     %RED%✗ TCP/IP stack reset failed%RESET%
    call :log "ERROR: TCP/IP stack reset failed"
)

echo   - Resetting IPv6 stack...
netsh int ipv6 reset >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ IPv6 stack reset successful%RESET%
    call :log "IPv6 stack reset successful"
) else (
    echo     %RED%✗ IPv6 stack reset failed%RESET%
    call :log "ERROR: IPv6 stack reset failed"
)

echo.

:: Step 2: Release and Renew IP Configuration
echo %BLUE%Step 2: Releasing and Renewing IP Configuration...%RESET%
call :log "Starting IP configuration reset"

echo   - Releasing current IP configuration...
ipconfig /release >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ IP configuration released%RESET%
    call :log "IP configuration released successfully"
) else (
    echo     %YELLOW%⚠ IP release completed with warnings%RESET%
    call :log "IP release completed with warnings"
)

echo   - Flushing DNS resolver cache...
ipconfig /flushdns >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ DNS cache flushed%RESET%
    call :log "DNS cache flushed successfully"
) else (
    echo     %RED%✗ DNS flush failed%RESET%
    call :log "ERROR: DNS flush failed"
)

echo   - Renewing IP configuration...
ipconfig /renew >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ IP configuration renewed%RESET%
    call :log "IP configuration renewed successfully"
) else (
    echo     %YELLOW%⚠ IP renewal completed with warnings%RESET%
    call :log "IP renewal completed with warnings"
)

echo.

:: Step 3: Additional Network Services Reset
echo %BLUE%Step 3: Resetting Additional Network Services...%RESET%
call :log "Starting additional network services reset"

echo   - Resetting HTTP proxy settings...
netsh winhttp reset proxy >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ HTTP proxy settings reset%RESET%
    call :log "HTTP proxy settings reset successfully"
) else (
    echo     %RED%✗ HTTP proxy reset failed%RESET%
    call :log "ERROR: HTTP proxy reset failed"
)

echo   - Resetting Firewall to default settings...
netsh advfirewall reset >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ Windows Firewall reset to defaults%RESET%
    call :log "Windows Firewall reset successfully"
) else (
    echo     %RED%✗ Firewall reset failed%RESET%
    call :log "ERROR: Firewall reset failed"
)

echo   - Clearing ARP cache...
arp -d * >nul 2>&1
echo     %GREEN%✓ ARP cache cleared%RESET%
call :log "ARP cache cleared"

echo   - Clearing NetBios name cache...
nbtstat -R >nul 2>&1
nbtstat -RR >nul 2>&1
echo     %GREEN%✓ NetBios name cache cleared%RESET%
call :log "NetBios name cache cleared"

echo.

:: Step 4: Restart Network Services
echo %BLUE%Step 4: Restarting Network Services...%RESET%
call :log "Starting network services restart"

set "SERVICES=Dnscache DHCP Netman NlaSvc Netlogon lanmanserver lanmanworkstation"

for %%s in (%SERVICES%) do (
    echo   - Restarting %%s service...
    net stop "%%s" >nul 2>&1
    timeout /t 2 /nobreak >nul
    net start "%%s" >nul 2>&1
    if !errorLevel! equ 0 (
        echo     %GREEN%✓ %%s service restarted%RESET%
        call :log "%%s service restarted successfully"
    ) else (
        echo     %YELLOW%⚠ %%s service restart failed or not applicable%RESET%
        call :log "WARNING: %%s service restart failed"
    )
)

echo.

:: Step 5: Display Final Network Status
echo %BLUE%Step 5: Final Network Configuration:%RESET%
echo %YELLOW%Updated Network Adapters:%RESET%
ipconfig | findstr /C:"Ethernet adapter" /C:"Wireless LAN adapter" /C:"IPv4 Address"
echo.

:: Final message and restart prompt
call :log "Network reset operation completed"
echo %GREEN%========================================%RESET%
echo %GREEN%  Network Reset Operation Completed!   %RESET%
echo %GREEN%========================================%RESET%
echo.
echo %YELLOW%What was accomplished:%RESET%
echo   • Winsock catalog reset
echo   • TCP/IP and IPv6 stack reset
echo   • IP configuration released and renewed
echo   • DNS cache flushed
echo   • HTTP proxy settings reset
echo   • Windows Firewall reset to defaults
echo   • ARP and NetBios caches cleared
echo   • Network services restarted
echo.
echo %BLUE%Log file saved to: %LOG_FILE%%RESET%
echo.

:: Restart prompt
set /p "RESTART=Do you want to restart your computer now? (Y/N): "
if /i "!RESTART!" equ "Y" (
    echo %YELLOW%Restarting computer in 10 seconds... Press Ctrl+C to cancel.%RESET%
    call :log "User chose to restart computer"
    timeout /t 10
    shutdown /r /t 0
) else (
    echo %YELLOW%Please restart your computer manually for all changes to take full effect.%RESET%
    call :log "User chose not to restart immediately"
)

echo.
echo %GREEN%Press any key to exit...%RESET%
pause >nul
exit /b 0
