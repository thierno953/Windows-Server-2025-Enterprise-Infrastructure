# Windows Server 2025 Enterprise Infrastructure

Enterprise-style Windows Server lab built to demonstrate **Active Directory, networking, security, PKI, file services, automation, and high availability** administration.

---

## Infrastructure

| System        | Role               | Address          |
| ------------- | ------------------ | ---------------- |
| `WS2025-DC01` | AD DS / DNS / DHCP | `192.168.1.10`   |
| `WS2025-DC02` | AD DS / DNS / DHCP | `192.168.1.11`   |
| `FILE01`      | File Server        | Dedicated server |
| `WIN11`       | Domain Client      | DHCP             |
| Gateway       | Network Gateway    | `192.168.1.1`    |

```text
Domain  : diarabaka.com
Network : 192.168.1.0/24
Platform: VMware
```

---

# Architecture

```text
                         DIARABAKA.COM
                              │
               ┌──────────────┴──────────────┐
               │                             │
               ▼                             ▼
        WS2025-DC01                    WS2025-DC02
        192.168.1.10                   192.168.1.11
               │                             │
          AD DS / DNS                   AD DS / DNS
             DHCP                         DHCP
               │                             │
               └──────── DHCP Failover ──────┘
                              │
                              ▼
                            WIN11
                              │
                              ├── Group Policy
                              ├── BitLocker
                              ├── Windows LAPS
                              ├── Certificates
                              └── LDAPS
                              │
                              ▼
                            FILE01
                              │
                    SMB / NTFS / FSRM
                              │
                        Backup / Restore
```

---

# Project Scope

## 01 - Active Directory Domain Services

Implemented:

- Active Directory forest and domain
- Two Domain Controllers
- Organizational Unit structure
- Users and security groups
- Administrative groups
- Password policy
- Account lockout policy
- FSMO role verification
- Global Catalog
- AD replication
- DCDIAG health validation

```text
WS2025-DC01 ↔ WS2025-DC02
Replication: Redundant AD infrastructure
```

---

## 02 - DNS

Implemented and tested:

- Active Directory-integrated DNS
- Forward lookup zones
- Reverse lookup zone
- A records
- PTR records
- LDAP / Kerberos / Global Catalog SRV records
- Internal domain resolution
- External DNS resolution
- DNS redundancy
- Controlled DNS failure testing

```text
DNS1 -> 192.168.1.10
DNS2 -> 192.168.1.11
```

---

## 03 - DHCP

Implemented:

- DHCP on both Domain Controllers
- Active Directory authorization
- IPv4 scope
- DHCP options
- Dynamic DNS
- Reservations
- DHCP lease validation
- DHCP Failover
- Load Balance mode
- Controlled failure and recovery testing

```text
Scope : 192.168.1.0/24

Pool:
192.168.1.100
      ↓
192.168.1.200

Failover:
WS2025-DC01 ↔ WS2025-DC02

Mode:
Load Balance 50 / 50
```

DHCP options:

```text
003 Router     -> 192.168.1.1
006 DNS        -> 192.168.1.10 / 192.168.1.11
015 DNS Domain -> diarabaka.com
```

---

## 04 - Group Policy

Implemented workstation security policies:

```text
GPO-WS-Security-Baseline
GPO-Windows11-BitLocker
GPO-Windows11-LAPS
```

Controls include:

- Windows Defender Firewall
- Microsoft Defender Antivirus
- Windows Update
- BitLocker
- TPM
- BitLocker recovery in Active Directory
- Windows LAPS
- Password rotation
- AD password backup
- Group Policy Result / RSoP
- SYSVOL validation

---

## 05 - BitLocker

Validated:

```text
TPM Present        : True
TPM Ready          : True
Encryption         : 100%
Protection         : On
Encryption Method  : XTS-AES
TPM Protector      : Present
Recovery Protector : Present
```

Architecture:

```text
GPO
 ↓
TPM
 ↓
BitLocker
 ↓
Recovery Password
 ↓
Active Directory Backup
```

Sensitive recovery keys are not included in this repository.

---

## 06 - Windows LAPS

Implemented:

- Windows LAPS schema
- Computer self permissions
- AD authorization
- LAPS Group Policy
- Password complexity
- Password rotation
- AD password backup
- Password encryption
- LAPS policy processing

```text
WIN11
  ↓
Windows LAPS
  ↓
Random Local Administrator Password
  ↓
Encrypted Backup
  ↓
Active Directory
```

No LAPS passwords are stored in screenshots or documentation.

---

## 07 - File Server

Dedicated Windows File Server:

```text
FILE01
```

Implemented:

- SMB shares
- NTFS permissions
- AGDLP authorization model
- Department isolation
- Access-Based Enumeration
- SMB security review
- File Server Resource Manager
- Hard quotas
- Capacity monitoring

Department shares:

```text
IT$
HR$
Finance$
Marketing$
Sales$
Public$
```

---

## 08 - AGDLP

Resource access follows:

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

This avoids assigning resource permissions directly to user accounts.

---

## 09 - Backup and Restore

Implemented backup validation workflow:

```text
Source Data
    ↓
Windows Server Backup
    ↓
Backup Version
    ↓
Alternate Restore
    ↓
SHA256 Validation
    ↓
ACL Verification
    ↓
SMB Functional Test
```

Validation includes:

- Separate backup target
- Backup version verification
- File restore
- SHA256 integrity comparison
- NTFS ACL verification
- Post-restore SMB access

```text
Backup completed
      ≠
Backup validated
```

---

# Security Administration

## 07 - Just Enough Administration

Implemented PowerShell JEA for delegated administration.

```text
AD User
   ↓
GG_ITAdmins
   ↓
JEA Endpoint
   ↓
ITAdmin Role Capability
   ↓
Restricted Cmdlets
   ↓
Virtual Administrator Account
```

Controls:

- Restricted PowerShell endpoint
- Role capabilities
- Cmdlet restrictions
- Parameter restrictions
- AD group authorization
- Virtual administrator account
- Session transcription

---

## 08 - Active Directory Certificate Services

Implemented an internal Microsoft PKI using:

```text
Active Directory Certificate Services
                ↓
        Enterprise CA
                ↓
      Certificate Templates
```

Validated:

- AD CS role
- Certificate Services
- Certificate Authority availability
- CA connectivity

---

## 09 - Certificate Templates

Configured certificate templates for domain resources.

```text
Enterprise CA
      ↓
Certificate Templates
      ↓
Users / Computers / Services
```

Template configuration includes:

- Enrollment permissions
- Cryptography
- Subject configuration
- Enhanced Key Usage
- Certificate validity

---

## TASK20 - Certificate Auto-Enrollment

Certificate enrollment is integrated with Group Policy.

```text
Active Directory
      ↓
Group Policy
      ↓
Auto-Enrollment
      ↓
Domain Computers
```

---

## TASK21 - User Certificates

Validated certificate enrollment for domain users.

```text
User
 ↓
Certificate Enrollment
 ↓
Enterprise CA
 ↓
User Certificate
```

---

## TASK22 - Computer Certificates

Validated computer certificate enrollment.

Certificates include appropriate Enhanced Key Usage such as:

```text
Server Authentication
```

for services requiring machine authentication.

---

## TASK23 - LDAPS

Implemented and validated LDAP over SSL/TLS.

```text
Enterprise CA
     ↓
Domain Controller Certificate
     ↓
Server Authentication
     ↓
TLS
     ↓
LDAPS
     ↓
TCP 636
```

Validated using the Windows `ldp.exe` client.

```text
Server : WS2025-DC01.diarabaka.com
Port   : 636
SSL    : Enabled
```

---

# Repository Structure

```text
Windows-Server-2025-Enterprise-Infrastructure/
│
├── 01-Infrastructure/
│
├── 02-Active-Directory/
│
├── 03-DNS/
│
├── 04-DHCP/
│
├── 05-Group-Policy/
│
├── 06-File-Server/
│
├── 07-JEA/
│
├── 08-ADCS-Certificate-Authority/
│
├── 09-Certificate-Templates/
│
├── 10-GPO-Certificate-AutoEnrollment/
│
├── 11-User-Certificate-Enrollment/
│
├── 12-Computer-Certificate-Enrollment/
│
└── 13-LDAPS/
```

Each section contains:

```text
README.md
assets/
└── validation screenshots
```

---

# Validation Method

The project follows a proof-based validation workflow:

```text
DISCOVER
   ↓
VERIFY
   ↓
CONFIGURE
   ↓
TEST
   ↓
EXPECTED = ACTUAL?
   ↓
EVIDENCE
   ↓
VALIDATED
```

A service is not considered validated simply because it is installed.

```text
INSTALLED
   ≠
CONFIGURED

CONFIGURED
   ≠
FUNCTIONAL

FUNCTIONAL
   ≠
VALIDATED

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
Restricted Administration
Encrypted Authentication
Centralized Identity
Redundancy
Backup and Recovery
Evidence-Based Validation
```

Sensitive information is excluded from the repository:

```text
Passwords
LAPS Secrets
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
Active Directory Certificate Services
PKI
Certificate Templates
Certificate Enrollment
Certificate Auto-Enrollment
LDAPS
Troubleshooting
High Availability
Security Hardening
Infrastructure Validation
```

---

# Final Architecture

```text
                    DIARABAKA.COM
                         │
            ┌────────────┴────────────┐
            │                         │
            ▼                         ▼
     WS2025-DC01               WS2025-DC02
     AD / DNS / DHCP           AD / DNS / DHCP
            │                         │
            └─────── Redundancy ─────┘
                         │
                         ▼
                       WIN11
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
       ▼                 ▼                 ▼
     GPO              Security            PKI
                       │                  │
                BitLocker/LAPS      AD CS / LDAPS
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
**Focus:** System Administration, Networking, Security & Identity
