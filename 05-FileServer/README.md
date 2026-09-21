# PHASE 06 - FILE SERVER

## Architecture

```text
USERS
  ↓
GLOBAL GROUPS
  ↓
DOMAIN LOCAL GROUPS
  ↓
SMB + NTFS
  ↓
FILE01
```

Example:

```text
mmartin
   ↓
GG-HR
   ↓
DL-FS-HR-Modify
   ↓
HR$
```

![FILE01](assets/01-file01-overview.png)

---

## Storage

```text
Shares
├── Departments
│   ├── IT
│   ├── HR
│   ├── Finance
│   ├── Marketing
│   └── Sales
└── Public
```

```powershell
Get-Disk
Get-Volume
```

![Storage](assets/02-storage-tree.png)

---

## AGDLP

| Global Group   | Resource Group           | Permission          |
| -------------- | ------------------------ | ------------------- |
| `GG-IT`        | `DL-FS-IT-Modify`        | `IT$` Modify        |
| `GG-HR`        | `DL-FS-HR-Modify`        | `HR$` Modify        |
| `GG-Finance`   | `DL-FS-Finance-Modify`   | `Finance$` Modify   |
| `GG-Marketing` | `DL-FS-Marketing-Modify` | `Marketing$` Modify |
| `GG-Sales`     | `DL-FS-Sales-Modify`     | `Sales$` Modify     |

```powershell
Get-ADGroupMember "DL-FS-HR-Modify"
```

![AGDLP](assets/03-agdlp-groups.png)

---

## SMB Shares

```text
IT$
HR$
Finance$
Marketing$
Sales$
Public$
```

```powershell
Get-SmbShare |
Where-Object Name -in @(
    'IT$','HR$','Finance$','Marketing$','Sales$','Public$'
) |
Select-Object Name,Path,FolderEnumerationMode,EncryptData
```

![SMB Shares](assets/04-smb-shares.png)

---

## SMB / NTFS ACL

```text
SMB Full
   +
NTFS Modify
   =
Effective Modify
```

```powershell
Get-SmbShareAccess -Name "HR$"

$HRPath = (Get-SmbShare -Name "HR$").Path
(Get-Acl $HRPath).Access
```

Administrative ACLs preserved:

```text
SYSTEM
BUILTIN\Administrators
```

![SMB NTFS ACL](assets/05-smb-ntfs-acl.png)

---

## Access Tests

HR user:

```text
\\FILE01\HR$
```

Result:

```text
Modify : Allowed
```

![Allowed Access](assets/06-access-allowed.png)

Negative test:

```powershell
Get-ChildItem "\\FILE01\Finance$" -ErrorAction Stop
```

Result:

```text
Access Denied
```

![Access Denied](assets/07-access-denied.png)

---

## SMB Security

```powershell
Get-SmbServerConfiguration |
Select-Object `
    EnableSMB1Protocol,
    EnableSMB2Protocol,
    EnableSecuritySignature,
    RequireSecuritySignature
```

```text
SMB1            : Disabled / Not Required
SMB2/SMB3       : Enabled
ABE             : Enabled
Least Privilege : Applied
```

![SMB Security](assets/08-smb-security.png)

---

## FSRM

```text
Department Quota : 5 GB
Type             : Hard
Thresholds       : 80% / 90% / 100%
```

```powershell
Get-FsrmQuota |
Select-Object Path,Size,Usage,SoftLimit,Description
```

![FSRM](assets/09-fsrm-quotas.png)

---

## Backup

```powershell
wbadmin get versions
```

```text
Backup target:
FILE01_BACKUP_TARGET (F:)

Can recover:
Volume(s), File(s)
```

![FILE01 Backup](assets/10-fileserver-backup.png)

---

## Restore Validation

Restored file:

```text
C:\Restore-Test\Backup-Test.txt
```

```powershell
Get-FileHash `
    "C:\Restore-Test\Backup-Test.txt" `
    -Algorithm SHA256
```

```text
D73A8BF5DAF8AFEED3392B31EF20E0CEC2A379B2D1D17BC394B8580AA90854B9
```

ACL validation:

```powershell
icacls "C:\Restore-Test\Backup-Test.txt"
```

Result:

```text
File restored    : PASS
SHA256           : PASS
ACL preservation : PASS
SMB validation   : PASS
```

![Restore Validation](assets/11-restore-validation.png)

---

## Final Validation

```powershell
Get-Service LanmanServer
Get-SmbShare
Get-SmbSession
Get-SmbOpenFile
```

```text
LanmanServer   : Running
SMB Shares     : Available
NTFS ACL       : Preserved
FSRM           : Functional
Client Access  : Functional
Isolation      : Functional
Backup         : Available
Restore        : Validated
```

![FILE01 Final Validation](assets/12-fileserver-final-validation.png)

### Validation

| Control              | Status |
| -------------------- | :----: |
| FILE01               |   ✅   |
| AGDLP                |   ✅   |
| SMB Shares           |   ✅   |
| SMB / NTFS ACL       |   ✅   |
| Department Isolation |   ✅   |
| ABE                  |   ✅   |
| SMB Security         |   ✅   |
| FSRM                 |   ✅   |
| Backup               |   ✅   |
| Restore              |   ✅   |
| SHA256               |   ✅   |
| ACL Preservation     |   ✅   |

**Status:** ✅ `VALIDATED`

---

# PROJECT STATUS

```text
PHASE 01 - ACTIVE DIRECTORY : VALIDATED
PHASE 02 - DNS              : VALIDATED
PHASE 03 - DHCP             : VALIDATED
PHASE 04 - GROUP POLICY     : VALIDATED
PHASE 05 - FILE SERVER      : VALIDATED
```

## Core Skills

`Windows Server 2025` · `Active Directory` · `DNS` · `DHCP` · `Group Policy` · `PowerShell` · `FSMO` · `Replication` · `BitLocker` · `Windows LAPS` · `AGDLP` · `SMB` · `NTFS` · `FSRM` · `Backup & Restore` · `Troubleshooting`
