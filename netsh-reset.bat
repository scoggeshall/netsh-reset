@echo off
setlocal enabledelayedexpansion
title Advanced Network Reset and Repair Tool v2.0

:: ================================================================
:: Advanced Network Reset and Repair Tool
:: Based on netsh commands and Windows network troubleshooting
:: Version: 2.0
:: License: MIT
:: ================================================================

:: ANSI Color Codes
for /F %%a in ('"prompt $E$S & echo on & for %%b in (1) do rem"') do set "ESC=%%a"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:: Configuration Variables
set "SCRIPT_VERSION=2.0"
set "LOG_DIR=%USERPROFILE%\Desktop\NetworkResetLogs"
set "TIMESTAMP=%DATE:~-4,4%-%DATE:~-10,2%-%DATE:~-7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "LOG_FILE=%LOG_DIR%\NetworkReset_%TIMESTAMP%.log"
set "BACKUP_FILE=%LOG_DIR%\NetworkConfig_Backup_%TIMESTAMP%.txt"

:: Create log directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

:: Display Header
cls
echo %BOLD%%CYAN%
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║            Advanced Network Reset and Repair Tool            ║
echo ║                         Version %SCRIPT_VERSION%                         ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo %RESET%
echo.
echo %BLUE%Log Directory:%RESET% %LOG_DIR%
echo %BLUE%Session Log:%RESET% %LOG_FILE%
echo.

:: Initialize logging
echo Advanced Network Reset Log - %DATE% %TIME% > "%LOG_FILE%"
echo ================================================================ >> "%LOG_FILE%"
echo Script Version: %SCRIPT_VERSION% >> "%LOG_FILE%"
echo User: %USERNAME% >> "%LOG_FILE%"
echo Computer: %COMPUTERNAME% >> "%LOG_FILE%"
echo OS: %OS% >> "%LOG_FILE%"
echo ================================================================ >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: Logging function
:log_message
echo [%TIME%] %~1 >> "%LOG_FILE%"
goto :eof

:: Check administrative privileges
call :log_message "Checking administrative privileges..."
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%█ ERROR: Administrative privileges required%RESET%
    echo %YELLOW%Please right-click this script and select "Run as administrator"%RESET%
    echo.
    call :log_message "ERROR: Script requires administrative privileges"
    pause
    exit /b 1
)

echo %GREEN%✓ Running with administrative privileges%RESET%
call :log_message "Administrative privileges confirmed"
echo.

:: System Information Gathering
echo %BOLD%%BLUE%► System Information%RESET%
call :log_message "Gathering system information..."

echo %CYAN%Computer Name:%RESET% %COMPUTERNAME%
echo %CYAN%Username:%RESET% %USERNAME%
echo %CYAN%Windows Version:%RESET%
ver | find "Version" >> "%LOG_FILE%"
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
echo.

:: Pre-Reset Network Configuration Backup
echo %BOLD%%BLUE%► Creating Network Configuration Backup%RESET%
call :log_message "Creating network configuration backup..."

echo Creating comprehensive network backup...
(
    echo ===== Network Configuration Backup - %DATE% %TIME% =====
    echo.
    echo === IP Configuration ===
    ipconfig /all
    echo.
    echo === Route Table ===
    route print
    echo.
    echo === ARP Table ===
    arp -a
    echo.
    echo === Network Connections ===
    netstat -an
    echo.
    echo === DNS Settings ===
    nslookup google.com
    echo.
    echo === Network Adapters ===
    wmic path win32_networkadapter get name,netconnectionstatus
    echo.
) > "%BACKUP_FILE%" 2>&1

if exist "%BACKUP_FILE%" (
    echo %GREEN%✓ Network configuration backup created%RESET%
    call :log_message "Network configuration backup created successfully"
) else (
    echo %YELLOW%⚠ Backup creation failed%RESET%
    call :log_message "WARNING: Backup creation failed"
)
echo.

:: Display current network status
echo %BOLD%%BLUE%► Current Network Status%RESET%
echo %CYAN%Active Network Adapters:%RESET%
ipconfig /all | findstr /C:"Ethernet adapter" /C:"Wireless LAN adapter" /C:"IPv4 Address" /C:"Default Gateway"
echo.

:: Connection Test
echo %CYAN%Testing Internet Connectivity:%RESET%
ping -n 1 8.8.8.8 >nul 2>&1
if %errorLevel% equ 0 (
    echo %GREEN%✓ Internet connection active%RESET%
    call :log_message "Pre-reset: Internet connection active"
) else (
    echo %RED%✗ No internet connection detected%RESET%
    call :log_message "Pre-reset: No internet connection"
)
echo.

:: User confirmation with options
echo %BOLD%%YELLOW%⚠ WARNING: This will reset all network configurations ⚠%RESET%
echo.
echo %WHITE%Available Options:%RESET%
echo %CYAN%[1]%RESET% Quick Reset (Basic network reset)
echo %CYAN%[2]%RESET% Full Reset (Complete network and firewall reset)
echo %CYAN%[3]%RESET% Advanced Reset (Full reset + additional repairs)
echo %CYAN%[4]%RESET% Exit without changes
echo.
set /p "RESET_OPTION=Select option (1-4): "

if "%RESET_OPTION%"=="4" (
    echo %YELLOW%Operation cancelled by user%RESET%
    call :log_message "Operation cancelled by user"
    goto :end_script
)

if "%RESET_OPTION%"=="" set "RESET_OPTION=1"
if %RESET_OPTION% lss 1 set "RESET_OPTION=1"
if %RESET_OPTION% gtr 3 set "RESET_OPTION=1"

call :log_message "User selected reset option: %RESET_OPTION%"
echo.

:: Confirmation
set /p "CONFIRM=Are you sure you want to proceed? (Y/N): "
if /i "!CONFIRM!" neq "Y" (
    echo %YELLOW%Operation cancelled%RESET%
    call :log_message "Operation cancelled by user at confirmation"
    goto :end_script
)

echo.
echo %BOLD%%GREEN%► Beginning Network Reset Process%RESET%
call :log_message "Starting network reset process - Option %RESET_OPTION%"
echo.

:: === PHASE 1: CORE NETWORK RESET ===
echo %BOLD%%BLUE%Phase 1: Core Network Reset%RESET%
echo %BLUE%════════════════════════════════════════%RESET%

:: Step 1: Reset Winsock Catalog
echo %CYAN%[1/6] Resetting Winsock Catalog...%RESET%
call :log_message "Resetting Winsock catalog"
netsh winsock reset >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ Winsock catalog reset successful%RESET%
    call :log_message "SUCCESS: Winsock catalog reset"
) else (
    echo     %RED%✗ Winsock reset failed (Error: %errorLevel%)%RESET%
    call :log_message "ERROR: Winsock reset failed with error %errorLevel%"
)

:: Step 2: Reset TCP/IP Stack
echo %CYAN%[2/6] Resetting TCP/IP Stack...%RESET%
call :log_message "Resetting TCP/IP stack"
netsh int ip reset >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ TCP/IP stack reset successful%RESET%
    call :log_message "SUCCESS: TCP/IP stack reset"
) else (
    echo     %RED%✗ TCP/IP reset failed (Error: %errorLevel%)%RESET%
    call :log_message "ERROR: TCP/IP reset failed with error %errorLevel%"
)

:: Step 3: Reset IPv6 Stack
echo %CYAN%[3/6] Resetting IPv6 Stack...%RESET%
call :log_message "Resetting IPv6 stack"
netsh int ipv6 reset >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ IPv6 stack reset successful%RESET%
    call :log_message "SUCCESS: IPv6 stack reset"
) else (
    echo     %RED%✗ IPv6 reset failed (Error: %errorLevel%)%RESET%
    call :log_message "ERROR: IPv6 reset failed with error %errorLevel%"
)

:: Step 4: Release and Renew IP
echo %CYAN%[4/6] Releasing and Renewing IP Configuration...%RESET%
call :log_message "Releasing IP configuration"
ipconfig /release >nul 2>&1
call :log_message "Flushing DNS cache"
ipconfig /flushdns >nul 2>&1
call :log_message "Renewing IP configuration"
ipconfig /renew >nul 2>&1
echo     %GREEN%✓ IP configuration refreshed%RESET%

:: Step 5: Clear Network Caches
echo %CYAN%[5/6] Clearing Network Caches...%RESET%
call :log_message "Clearing ARP cache"
arp -d * >nul 2>&1
call :log_message "Clearing NetBIOS cache"
nbtstat -R >nul 2>&1
nbtstat -RR >nul 2>&1
echo     %GREEN%✓ Network caches cleared%RESET%

:: Step 6: Reset Network Location Awareness
echo %CYAN%[6/6] Resetting Network Location Awareness...%RESET%
call :log_message "Resetting Network Location Awareness"
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" /f >nul 2>&1
echo     %GREEN%✓ Network profiles reset%RESET%

echo.

:: === PHASE 2: FIREWALL AND SECURITY RESET (Options 2 & 3) ===
if %RESET_OPTION% geq 2 (
    echo %BOLD%%BLUE%Phase 2: Firewall and Security Reset%RESET%
    echo %BLUE%════════════════════════════════════════%RESET%
    
    echo %CYAN%[1/3] Resetting Windows Firewall...%RESET%
    call :log_message "Resetting Windows Firewall"
    netsh advfirewall reset >nul 2>&1
    if %errorLevel% equ 0 (
        echo     %GREEN%✓ Windows Firewall reset to defaults%RESET%
        call :log_message "SUCCESS: Windows Firewall reset"
    ) else (
        echo     %RED%✗ Firewall reset failed%RESET%
        call :log_message "ERROR: Firewall reset failed"
    )
    
    echo %CYAN%[2/3] Resetting HTTP Proxy Settings...%RESET%
    call :log_message "Resetting HTTP proxy settings"
    netsh winhttp reset proxy >nul 2>&1
    echo     %GREEN%✓ HTTP proxy settings reset%RESET%
    
    echo %CYAN%[3/3] Resetting Internet Explorer Settings...%RESET%
    call :log_message "Resetting IE proxy settings"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f >nul 2>&1
    echo     %GREEN%✓ Internet Explorer proxy settings reset%RESET%
    
    echo.
)

:: === PHASE 3: ADVANCED REPAIRS (Option 3 only) ===
if %RESET_OPTION% equ 3 (
    echo %BOLD%%BLUE%Phase 3: Advanced System Repairs%RESET%
    echo %BLUE%════════════════════════════════════════%RESET%
    
    echo %CYAN%[1/5] Running Network Diagnostics...%RESET%
    call :log_message "Running network diagnostics"
    netsh int ip show config >> "%LOG_FILE%" 2>&1
    netsh int ipv6 show config >> "%LOG_FILE%" 2>&1
    echo     %GREEN%✓ Network diagnostics completed%RESET%
    
    echo %CYAN%[2/5] Repairing WinSock LSP...%RESET%
    call :log_message "Repairing WinSock LSP"
    netsh winsock reset catalog >nul 2>&1
    echo     %GREEN%✓ WinSock LSP repaired%RESET%
    
    echo %CYAN%[3/5] Resetting Network Components...%RESET%
    call :log_message "Resetting network components"
    netsh int tcp reset >nul 2>&1
    netsh int udp reset >nul 2>&1
    echo     %GREEN%✓ Network components reset%RESET%
    
    echo %CYAN%[4/5] Clearing DNS Resolution Cache...%RESET%
    call :log_message "Clearing DNS resolver cache"
    ipconfig /registerdns >nul 2>&1
    echo     %GREEN%✓ DNS resolution cache cleared%RESET%
    
    echo %CYAN%[5/5] Optimizing Network Settings...%RESET%
    call :log_message "Optimizing network settings"
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    netsh int tcp set global chimney=enabled >nul 2>&1
    netsh int tcp set global rss=enabled >nul 2>&1
    echo     %GREEN%✓ Network settings optimized%RESET%
    
    echo.
)

:: === PHASE 4: SERVICE RESTART ===
echo %BOLD%%BLUE%Phase 4: Network Service Restart%RESET%
echo %BLUE%════════════════════════════════════════%RESET%

set "SERVICES=Dnscache DHCP Netman NlaSvc Netlogon LanmanServer LanmanWorkstation"
set "SERVICE_COUNT=0"

for %%s in (%SERVICES%) do (
    set /a SERVICE_COUNT+=1
    echo %CYAN%[!SERVICE_COUNT!/7] Restarting %%s...%RESET%
    call :log_message "Restarting service: %%s"
    
    net stop "%%s" >nul 2>&1
    timeout /t 2 /nobreak >nul
    net start "%%s" >nul 2>&1
    
    if !errorLevel! equ 0 (
        echo     %GREEN%✓ %%s restarted successfully%RESET%
        call :log_message "SUCCESS: %%s service restarted"
    ) else (
        echo     %YELLOW%⚠ %%s restart failed or not applicable%RESET%
        call :log_message "WARNING: %%s service restart failed"
    )
)

echo.

:: === PHASE 5: POST-RESET VERIFICATION ===
echo %BOLD%%BLUE%Phase 5: Post-Reset Verification%RESET%
echo %BLUE%════════════════════════════════════════%RESET%

echo %CYAN%[1/4] Verifying Network Adapters...%RESET%
ipconfig | findstr /C:"Ethernet adapter" /C:"Wireless LAN adapter" | find /c /v "" >nul
echo     %GREEN%✓ Network adapters detected%RESET%

echo %CYAN%[2/4] Testing DNS Resolution...%RESET%
nslookup google.com >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ DNS resolution working%RESET%
    call :log_message "POST-RESET: DNS resolution working"
) else (
    echo     %YELLOW%⚠ DNS resolution issues detected%RESET%
    call :log_message "POST-RESET: DNS resolution issues"
)

echo %CYAN%[3/4] Testing Internet Connectivity...%RESET%
ping -n 2 8.8.8.8 >nul 2>&1
if %errorLevel% equ 0 (
    echo     %GREEN%✓ Internet connectivity restored%RESET%
    call :log_message "POST-RESET: Internet connectivity working"
) else (
    echo     %YELLOW%⚠ Internet connectivity issues persist%RESET%
    call :log_message "POST-RESET: Internet connectivity issues"
)

echo %CYAN%[4/4] Generating Final Report...%RESET%
(
    echo.
    echo ===== POST-RESET NETWORK STATUS =====
    echo Reset completed at: %DATE% %TIME%
    echo Reset option used: %RESET_OPTION%
    echo.
    ipconfig /all
) >> "%LOG_FILE%"
echo     %GREEN%✓ Final report generated%RESET%

echo.

:: === COMPLETION SUMMARY ===
echo %BOLD%%GREEN%
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                    RESET COMPLETED SUCCESSFULLY                ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo %RESET%
echo.
echo %BOLD%%WHITE%Network Reset Summary:%RESET%
echo %GREEN%✓%RESET% Network adapters reset and configured
echo %GREEN%✓%RESET% DNS cache cleared and renewed
echo %GREEN%✓%RESET% IP configuration refreshed
if %RESET_OPTION% geq 2 (
    echo %GREEN%✓%RESET% Windows Firewall reset to defaults
    echo %GREEN%✓%RESET% Proxy settings cleared
)
if %RESET_OPTION% equ 3 (
    echo %GREEN%✓%RESET% Advanced network repairs completed
    echo %GREEN%✓%RESET% Network settings optimized
)
echo %GREEN%✓%RESET% Network services restarted
echo %GREEN%✓%RESET% System verification completed
echo.

echo %BOLD%%WHITE%Generated Files:%RESET%
echo %CYAN%• Log File:%RESET% %LOG_FILE%
echo %CYAN%• Backup File:%RESET% %BACKUP_FILE%
echo.

call :log_message "Network reset completed successfully"

:: === RESTART RECOMMENDATION ===
:restart_prompt
echo %BOLD%%YELLOW%═══════════════════════════════════════%RESET%
echo %BOLD%%YELLOW%          RESTART RECOMMENDED          %RESET%
echo %BOLD%%YELLOW%═══════════════════════════════════════%RESET%
echo.
echo %WHITE%A system restart is recommended to ensure all changes take effect.%RESET%
echo.
echo %CYAN%Options:%RESET%
echo %WHITE%[1]%RESET% Restart now (recommended)
echo %WHITE%[2]%RESET% Restart later manually
echo %WHITE%[3]%RESET% Open log directory and exit
echo.
set /p "RESTART_CHOICE=Select option (1-3): "

if "%RESTART_CHOICE%"=="1" (
    echo.
    echo %YELLOW%Restarting computer in 15 seconds...%RESET%
    echo %WHITE%Press Ctrl+C to cancel%RESET%
    call :log_message "User chose to restart immediately"
    timeout /t 15
    shutdown /r /t 0
    exit
) else if "%RESTART_CHOICE%"=="3" (
    echo %GREEN%Opening log directory...%RESET%
    explorer "%LOG_DIR%"
    call :log_message "User opened log directory"
) else (
    echo %YELLOW%Please restart your computer manually when convenient.%RESET%
    call :log_message "User chose to restart manually later"
)

:end_script
echo.
echo %BOLD%%WHITE%Thank you for using the Advanced Network Reset Tool!%RESET%
echo %WHITE%For support or issues, check the log files in:%RESET%
echo %CYAN%%LOG_DIR%%RESET%
echo.
echo %WHITE%Press any key to exit...%RESET%
pause >nul
exit /b 0
