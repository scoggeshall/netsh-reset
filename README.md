# Network Reset Tool

Version: 2.0  
Author: scoggeshall  
License: MIT

---

## Overview

This is a streamlined Windows batch script designed to quickly reset and repair essential network settings using built-in system tools. It flushes DNS, resets TCP/IP and Winsock, clears ARP and NetBIOS caches, resets firewall and proxy settings, and logs everything to a timestamped file.

---

## Features

- One-click full network reset
- Automatically logs all actions and errors
- Creates per-run log files with timestamp
- Optionally prompts for system reboot
- Minimal UI, no external dependencies

---

## Log File Location

- `%UserProfile%\Desktop\NetResetLogs\reset_YYYY-MM-DD_HH-MM.log`

Includes details of every step and the full `ipconfig /all` output for reference.

---

## Requirements

- Windows 10 or later
- Must be run as Administrator

---

## How to Use

1. Right-click the `.bat` file and choose **"Run as administrator"**
2. Follow the on-screen instructions
3. After the reset, choose whether to reboot now or later

---

## What It Resets

- Winsock catalog
- TCP/IP stack (IPv4 and IPv6)
- DNS cache
- ARP and NetBIOS name caches
- Windows Firewall
- Proxy settings (via `winhttp`)
- Displays full adapter configuration afterward

---

## License

This project is licensed under the MIT License.

---

## Support

Check the log files for any errors or output.  
For updates or improvements, visit: [https://github.com/scoggeshall/netsh-reset](https://github.com/scoggeshall/netsh-reset)
