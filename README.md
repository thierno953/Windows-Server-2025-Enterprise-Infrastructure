# Windows Server 2025 Enterprise Infrastructure

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
                   ┌───────────┴───────────┐
                   ▼                       ▼
                 WIN11                   FILE01
             Domain Client              File Server
```

---

## Project Phases

| Phase                     | Component        | Key Features                                           | Status |
| ------------------------- | ---------------- | ------------------------------------------------------ | :----: |
| [01](01-ActiveDirectory/) | Active Directory | AD DS, OU, users, groups, FSMO, replication, backup    |   ✅   |
| [02](02-DNS/)             | DNS              | AD-integrated DNS, A/PTR/SRV, redundancy, DC Locator   |   ✅   |
| [03](03-DHCP/)            | DHCP             | Scope, options, DDNS, reservations, failover 50/50     |   ✅   |
| [04](04-GroupPolicy/)     | Group Policy     | Security baseline, BitLocker, LAPS, SYSVOL, GPO backup |   ✅   |
| [05](05-FileServer/)      | File Server      | AGDLP, SMB, NTFS, FSRM, backup, restore                |   ✅   |

---

## Core Technologies

`Windows Server 2025`
`Active Directory Domain Services`
`DNS`
`DHCP`
`Group Policy`
`PowerShell`
`BitLocker`
`Windows LAPS`
`AGDLP`
`SMB / NTFS`
`FSRM`
`Windows Server Backup`

---

## Security

```text
Least Privilege
      +
Administrative Account Separation
      +
Secure DNS
      +
BitLocker
      +
Windows LAPS
      +
AGDLP
      +
SMB / NTFS Security
      +
Backup / Restore
```

Sensitive data such as passwords, LAPS credentials, BitLocker recovery keys, and secrets are redacted from evidence.

---

## Validation

The project includes real configuration and validation evidence:

```text
CONFIGURE
    ↓
TEST
    ↓
FAILURE TEST
    ↓
RECOVERY
    ↓
VALIDATION
    ↓
SCREENSHOT / COMMAND OUTPUT
```

Validated areas:

- AD replication
- DNS resolution
- DHCP failover
- GPO application
- BitLocker recovery
- Windows LAPS
- Department isolation
- SMB / NTFS permissions
- Backup and restore
- SHA256 integrity validation

---

## Repository Structure

```text
X10THINK/
│
├── README.md
│
├── 01-ActiveDirectory/
│   ├── README.md
│   └── assets/
│
├── 02-DNS/
│   ├── README.md
│   └── assets/
│
├── 03-DHCP/
│   ├── README.md
│   └── assets/
│
├── 04-GroupPolicy/
│   ├── README.md
│   └── assets/
│
└── 05-FileServer/
    ├── README.md
    └── assets/
```

---

## Skills Demonstrated

`Windows Administration` · `Active Directory` · `DNS` · `DHCP` · `GPO` · `PowerShell` · `FSMO` · `Replication` · `BitLocker` · `Windows LAPS` · `AGDLP` · `SMB` · `NTFS` · `FSRM` · `Backup & Recovery` · `Troubleshooting` · `High Availability`

---

## Final Status

```text
ACTIVE DIRECTORY : VALIDATED
DNS              : VALIDATED
DHCP             : VALIDATED
GROUP POLICY     : VALIDATED
FILE SERVER      : VALIDATED
BACKUP / RESTORE : VALIDATED
```
