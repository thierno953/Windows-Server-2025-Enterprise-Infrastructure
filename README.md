# Windows Server 2025 Enterprise Infrastructure

![Windows Server](https://img.shields.io/badge/Windows%20Server-2025-0078D4)
![PowerShell](https://img.shields.io/badge/PowerShell-Automation-5391FE)
![Status](https://img.shields.io/badge/Status-Validated-brightgreen)
![Platform](https://img.shields.io/badge/Platform-VMware-lightgrey)

Enterprise Windows infrastructure lab built with **Windows Server 2025**, Active Directory, DNS, DHCP, Group Policy, File Services, and PowerShell.

**Domain:** `diarabaka.com`

**Network:** `192.168.1.0/24`

**Status:** ✅ `VALIDATED / COMPLETED`

---

## Architecture

```text
                    DIARABAKA.COM
                          │
           ┌──────────────┴──────────────┐
           ▼                             ▼
         DC01                          DC02
   192.168.1.10                   192.168.1.11
  AD DS / DNS / DHCP             AD DS / DNS / DHCP
           │                             │
           └──────────────┬──────────────┘
                          │
                    AD Replication
                          │
                ┌─────────┴─────────┐
                ▼                   ▼
              WIN11               FILE01
          Domain Client          File Server
```

---

## Project Phases

| Phase                     | Component               | Status |
| ------------------------- | ----------------------- | :----: |
| [02](02-ActiveDirectory/) | Active Directory        |   ✅   |
| [03](03-DNS/)             | DNS                     |   ✅   |
| [04](04-DHCP/)            | DHCP                    |   ✅   |
| [05](05-GroupPolicy/)     | Group Policy / Security |   ✅   |
| [06](06-FileServer/)      | File Server             |   ✅   |

---

## Evidence

### Active Directory

![Active Directory](01-ActiveDirectory/captures/09-dcdiag-health.png)

### DHCP Failover

![DHCP Failover](03-DHCP/captures/08-dhcp-failover.png)

### Group Policy / BitLocker

![BitLocker](04-GroupPolicy/captures/06-bitlocker-status.png)

### File Server

![File Server](05-FileServer/captures/04-smb-shares.png)

> Additional commands, screenshots, and validation results are available in each phase.

---

## Key Technologies

`Windows Server 2025` · `Active Directory` · `DNS` · `DHCP` · `Group Policy` · `PowerShell` · `BitLocker` · `Windows LAPS` · `AGDLP` · `SMB` · `NTFS` · `FSRM` · `Backup & Restore`

---

## How to Reproduce

Requirements:

```text
VMware
Windows Server 2025
Windows 11
PowerShell
```

Deployment order:

```text
01. Prepare virtual machines
02. Deploy Active Directory
03. Configure DNS
04. Configure DHCP Failover
05. Apply Group Policies
06. Configure FILE01
07. Validate services
08. Test failure / recovery
```

Detailed commands are available in each phase README.

---

## Repository Structure

```text
Windows-Server-2025-Enterprise-Infrastructure/
│
├── README.md
├── 01-ActiveDirectory/
├── 02-DNS/
├── 03-DHCP/
├── 04-GroupPolicy/
└── 05-FileServer/
```

---

## Related Project

Linux infrastructure portfolio:

[Linux Infrastructure Project]

---

## Security

Sensitive information is redacted from screenshots and command outputs:

- passwords
- Windows LAPS credentials
- BitLocker recovery keys
- secrets and tokens

---

## License

This project is available under the **MIT License**.
