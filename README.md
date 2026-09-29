# Windows Server 2025 Enterprise Infrastructure

Enterprise Windows Server lab covering **Active Directory, DNS, DHCP, Group Policy, security, file services, PKI, JEA, backup/restore, and LDAPS**.

---

## Infrastructure

| System        | Role               | Address          |
| ------------- | ------------------ | ---------------- |
| `WS2025-DC01` | AD DS / DNS / DHCP | `192.168.1.10`   |
| `WS2025-DC02` | AD DS / DNS / DHCP | `192.168.1.11`   |
| `FILE01`      | File Server        | Dedicated Server |
| `WIN11`       | Domain Client      | DHCP             |
| Enterprise CA | AD CS / PKI        | Dedicated Server |
| Gateway       | Network Gateway    | `192.168.1.1`    |

```text
Domain   : diarabaka.com
Network  : 192.168.1.0/24
Platform : VMware
```

---

# Architecture

```text
                         DIARABAKA.COM
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
       WS2025-DC01                      WS2025-DC02
       192.168.1.10                     192.168.1.11
              │                               │
        AD DS / DNS / DHCP              AD DS / DNS / DHCP
              │                               │
              └──────── DHCP Failover ────────┘
                              │
                              ▼
                            WIN11
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
            GPO           BitLocker/LAPS    Certificates
                                               │
                                               ▼
                                      Enterprise CA Server
                                               │
                                      Certificate Issuance
                                               │
                                               ▼
                                      Domain Controller
                                               │
                                          LDAPS : 636
                              │
                              ▼
                            FILE01
                              │
                       SMB / NTFS
                              │
                       AGDLP / FSRM
                              │
                      Backup / Restore
```

---

# 01 - Active Directory

Implemented:

- Two Domain Controllers
- Organizational Units
- Users and security groups
- Password and lockout policies
- FSMO verification
- Global Catalog
- AD replication
- DCDIAG validation

```text
WS2025-DC01 <-> WS2025-DC02
```

---

# 02 - DNS

Implemented:

- AD-integrated DNS
- Forward and reverse zones
- A / PTR records
- LDAP / Kerberos / GC SRV records
- Internal and external resolution
- DNS redundancy
- Failure and recovery testing

```text
DNS1 : 192.168.1.10
DNS2 : 192.168.1.11
```

---

# 03 - DHCP

Implemented:

- DHCP on both Domain Controllers
- AD authorization
- IPv4 scope
- DHCP options
- Reservations
- Dynamic DNS
- Lease validation
- DHCP Failover
- Load Balance 50/50
- Failure and recovery testing

```text
Scope : 192.168.1.0/24
Pool  : 192.168.1.100 - 192.168.1.200

003 Router     : 192.168.1.1
006 DNS        : 192.168.1.10 / 192.168.1.11
015 DNS Domain : diarabaka.com
```

---

# 04 - Group Policy

Implemented:

```text
GPO-WS-Security-Baseline
GPO-Windows11-BitLocker
GPO-Windows11-LAPS
```

Controls:

- Windows Defender Firewall
- Microsoft Defender Antivirus
- Windows Update
- BitLocker
- Windows LAPS
- RSoP / GPResult
- SYSVOL validation

---

# 05 - BitLocker

Validated:

```text
TPM Present        : True
TPM Ready          : True
Encryption         : 100%
Protection         : On
TPM Protector      : Present
Recovery Protector : Present
AD Backup          : Configured
```

```text
GPO
 ↓
TPM
 ↓
BitLocker
 ↓
Recovery Password
 ↓
Active Directory
```

> Recovery keys are not stored in this repository.

---

# 06 - Windows LAPS

Implemented:

- Windows LAPS schema
- OU self permissions
- LAPS GPO
- Password complexity
- Password rotation
- Password encryption
- Active Directory backup
- Policy processing

```text
WIN11
  ↓
Windows LAPS
  ↓
Random Local Admin Password
  ↓
Encrypted AD Backup
```

> LAPS passwords are not stored in screenshots or documentation.

---

# 07 - File Server

Server:

```text
FILE01
```

Implemented:

- SMB shares
- NTFS permissions
- AGDLP
- Department isolation
- Access-Based Enumeration
- SMB security review
- FSRM
- Hard quotas
- Capacity monitoring

Shares:

```text
IT$
HR$
Finance$
Marketing$
Sales$
Public$
```

---

# 08 - AGDLP

Authorization model:

```text
Accounts
   ↓
Global Groups
   ↓
Domain Local Groups
   ↓
Permissions
```

Example:

```text
HR User
   ↓
GG-HR
   ↓
DL-FS-HR-Modify
   ↓
NTFS Modify
   ↓
HR$
```

---

# 09 - Backup and Restore

Validation workflow:

```text
Source Data
    ↓
Backup
    ↓
Backup Version
    ↓
Alternate Restore
    ↓
SHA256 Validation
    ↓
ACL Verification
    ↓
SMB Access Test
```

Validated through:

- Separate backup target
- Backup version verification
- File restore
- SHA256 comparison
- NTFS ACL verification
- SMB post-restore test

```text
Backup completed != Backup validated
```

---

# 10 - Just Enough Administration

Implemented **PowerShell JEA** for delegated administration.

```text
AD User
   ↓
GG_ITAdmins
   ↓
JEA Endpoint
   ↓
ITAdmin Role
   ↓
Restricted Cmdlets
   ↓
Virtual Administrator Account
```

Controls:

- Role Capability
- Restricted session
- AD group authorization
- Cmdlet restrictions
- Parameter restrictions
- Virtual account
- Session transcription

---

# 11 - Active Directory Certificate Services

A dedicated server hosts the internal **Enterprise Certificate Authority**.

```text
Dedicated CA Server
       ↓
AD CS
       ↓
Enterprise CA
       ↓
Certificate Templates
       ↓
Certificate Issuance
```

Validated:

- AD CS role
- `CertSvc`
- Enterprise CA
- CA connectivity

---

# 12 - Certificate Services

Implemented:

- Certificate Templates
- User Certificate Enrollment
- Computer Certificate Enrollment
- Group Policy Auto-Enrollment
- Server Authentication certificates

```text
Enterprise CA
      ↓
Certificate Templates
      ↓
Enrollment / Auto-Enrollment
      ↓
Users / Computers / Servers
```

---

# 13 - LDAPS

Implemented and validated **LDAP over SSL/TLS**.

The Enterprise CA and Domain Controller are **separate systems**.

```text
Enterprise CA Server
        ↓
Issues Certificate
        ↓
Domain Controller
        ↓
Server Authentication Certificate
        ↓
TLS
        ↓
LDAPS TCP 636
        ↓
Windows Client
```

Validation:

```text
DC Certificate        : Present
Private Key           : Present
Server Authentication : Enabled
Certificate           : Valid
LDAPS Port             : 636
SSL/TLS Connection    : Successful
```

Validated using:

```text
Certificates MMC
ldp.exe
```

---

# Repository Structure

```text
Windows-Server-2025-Enterprise-Infrastructure/
│
├── 01-Active-Directory/
├── 02-DNS/
├── 03-DHCP/
├── 04-Group-Policy/
├── 05-BitLocker-LAPS/
├── 06-File-Server/
├── 07-JEA/
├── 08-ADCS-Certificate-Authority/
├── 09-Certificate-Templates/
├── 10-GPO-Certificate-AutoEnrollment/
├── 11-User-Certificate-Enrollment/
├── 12-Computer-Certificate-Enrollment/
└── 13-LDAPS/
```

Each section contains:

```text
README.md
assets/
└── screenshots
```

---

# Validation Method

```text
DISCOVER
   ↓
VERIFY
   ↓
CONFIGURE
   ↓
TEST
   ↓
EXPECTED = ACTUAL
   ↓
EVIDENCE
   ↓
VALIDATED
```

```text
INSTALLED != CONFIGURED
CONFIGURED != FUNCTIONAL
FUNCTIONAL != VALIDATED

EXPECTED = ACTUAL + EVIDENCE
           =
        VALIDATED
```

---

# Security Principles

```text
Least Privilege
Defense in Depth
Role-Based Administration
AGDLP
JEA
Centralized Identity
Encrypted Authentication
Redundancy
Backup and Recovery
Evidence-Based Validation
```

Sensitive data excluded:

```text
Passwords
LAPS Passwords
BitLocker Recovery Keys
Private Keys
Shared Secrets
Credentials
```

---

# Skills Demonstrated

```text
Windows Server 2025
Active Directory Domain Services
DNS
DHCP
DHCP Failover
PowerShell
Group Policy
Windows Defender
Windows Firewall
BitLocker
TPM
Windows LAPS
SMB
NTFS
AGDLP
FSRM
Windows Server Backup
Backup and Restore
SHA256 Validation
JEA
AD CS
PKI
Certificate Templates
Certificate Enrollment
Certificate Auto-Enrollment
LDAPS
Troubleshooting
High Availability
Security Hardening
```

---

# Final Architecture

```text
                       DIARABAKA.COM
                            │
             ┌──────────────┴──────────────┐
             │                             │
             ▼                             ▼
      WS2025-DC01                    WS2025-DC02
      AD / DNS / DHCP                AD / DNS / DHCP
             │                             │
             └──────── Redundancy ─────────┘
                            │
                            ▼
                          WIN11
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
       GPO             BitLocker/LAPS           PKI
                                                │
                                      Dedicated CA Server
                                                │
                                      Certificate Issuance
                                                │
                                                ▼
                                      Domain Controller
                                                │
                                           LDAPS : 636
                            │
                            ▼
                          FILE01
                            │
                    SMB / NTFS / AGDLP
                            │
                       FSRM / Backup
                            │
                          Restore
```

---

## Project

**Windows Server 2025 Enterprise Infrastructure**

**Domain:** `diarabaka.com`  
**Platform:** VMware  
**Focus:** System Administration, Networking, Security, Identity & PKI
