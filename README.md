# Network Reset and Repair Tool

Version: 2.0  
Author: scoggeshall  
License: MIT

---

## Overview

This is an advanced Windows batch script that automates the process of resetting and repairing network settings. It uses built-in tools like `netsh`, `ipconfig`, `nbtstat`, `arp`, and `reg` to help restore internet connectivity, flush caches, reset firewalls, and more.

---

## Features

- Color-coded, interactive command-line interface
- Logs all actions to a detailed timestamped file
- Backs up current network configuration before making changes
- Multiple reset options:
  - Quick Reset (basic TCP/IP and Winsock reset)
  - Full Reset (adds firewall and proxy reset)
  - Advanced Reset (includes additional diagnostic and optimization steps)
- Verifies connectivity and DNS before and after reset
- Restarts critical networking services
- Offers reboot prompt at the end

---

## Files Created

- Log File: `%UserProfile%\Desktop\NetworkResetLogs\NetworkReset_YYYY-MM-DD_HH-MM-SS.log`
- Backup File: `%UserProfile%\Desktop\NetworkResetLogs\NetworkConfig_Backup_YYYY-MM-DD_HH-MM-SS.txt`

---

## Requirements

- Windows 10 or later
- Must be run as Administrator

---

## How to Use

1. Right-click the script and select **"Run as administrator"**
2. Choose one of the following options when prompted:
   - [1] Quick Reset
   - [2] Full Reset
   - [3] Advanced Reset
   - [4] Exit
3. Confirm you want to proceed
4. After the reset completes, choose whether to restart now or later

---

## Warning

This script will reset and modify key network settings, including:

- TCP/IP and IPv6 stacks
- Winsock catalog
- Windows Firewall settings
- Proxy and DNS cache
- Network location profiles

Please back up any important configuration before running.

---

## License

This project is licensed under the MIT License.

---

## Support

Check the generated log files for detailed info.  
For issues or improvements, visit: https://github.com/scoggeshall/netsh-reset
