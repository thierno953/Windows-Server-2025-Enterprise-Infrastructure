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

![SMB Security](assets/08-smb-security.png)

```text
SMB1            : Disabled / Not Required
SMB2/SMB3       : Enabled
ABE             : Enabled
Least Privilege : Applied
```

---

## FSRM

```text
Department Quota : 5 GB
Type             : Hard
Thresholds       : 80% / 90% / 100%
```

![FSRM](assets/09-fsrm-quotas.png)

---

## Backup

![FILE01 Backup](assets/10-fileserver-backup.png)

```text
Backup target:
FILE01_BACKUP_TARGET (F:)

Can recover:
Volume(s), File(s)
```

---

## Restore Validation

Restored file:

```text
C:\Restore-Test\Backup-Test.txt
```

![Restore Validation](assets/11-restore-validation.png)

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

---

## SMB / NTFS Permissions

![FILE01 Final Validation](assets/12-fileserver-final-validation.png)

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
