# FILE SERVER

## 01 - FILE01 Baseline

```text
Server       : FILE01
Domain       : diarabaka.com
Role         : File Server
SMB Service  : Running
```

![FILE01 Baseline](assets/01-file01-baseline.png)

---

## 02 - Storage

```text
FILE01
│
├── System Volume
│
└── Data Volume
    └── Shares
        ├── Departments
        │   ├── IT
        │   ├── HR
        │   ├── Finance
        │   ├── Marketing
        │   └── Sales
        └── Public
```

![FILE01 Storage](assets/02-file01-storage.png)

---

## 03 - AGDLP

Authorization model:

```text
USER
  ↓
GLOBAL GROUP
  ↓
DOMAIN LOCAL GROUP
  ↓
SMB / NTFS PERMISSION
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

| Global Group   | Resource Group           | Resource     |
| -------------- | ------------------------ | ------------ |
| `GG-IT`        | `DL-FS-IT-Modify`        | `IT$`        |
| `GG-HR`        | `DL-FS-HR-Modify`        | `HR$`        |
| `GG-Finance`   | `DL-FS-Finance-Modify`   | `Finance$`   |
| `GG-Marketing` | `DL-FS-Marketing-Modify` | `Marketing$` |
| `GG-Sales`     | `DL-FS-Sales-Modify`     | `Sales$`     |

![AGDLP](assets/03-file-server-agdlp.png)

---

## 04 - SMB Shares

```text
IT$
HR$
Finance$
Marketing$
Sales$
Public$
```

Access-Based Enumeration is enabled on the departmental shares.

![SMB Shares](assets/04-smb-shares.png)

---

## 05 - SMB Permissions

Resource permissions are assigned through Domain Local groups.

```text
HR$
    ↓
DIARABAKA\DL-FS-HR-Modify

Finance$
    ↓
DIARABAKA\DL-FS-Finance-Modify

IT$
    ↓
DIARABAKA\DL-FS-IT-Modify
```

![SMB Permissions](assets/05-smb-permissions.png)

---

## 06 - NTFS Permissions

Permission model:

```text
SMB Full
   +
NTFS Modify
   =
Effective Modify
```

Administrative permissions are preserved:

```text
SYSTEM
BUILTIN\Administrators
```

Department resource groups receive NTFS `Modify` permissions.

![NTFS Permissions](assets/06-ntfs-permissions.png)

---

## 07 - Positive Access Test

A user belonging to the HR department was used to validate access to:

```text
\\FILE01\HR$
```

Validation:

```text
TCP 445       : Reachable
HR$ Access    : Allowed
File Creation : Successful
File Read     : Successful
```

![HR Positive Access](assets/07-hr-positive-access.png)

---

## 08 - Department Isolation

A negative access test was performed using the HR account against another department share.

Example:

```text
HR User
   ↓
Finance$
   ↓
ACCESS DENIED
```

This validates departmental isolation and least-privilege access.

![Department Isolation](assets/08-department-isolation.png)

---

## 09 - FSRM Quotas

File Server Resource Manager is used to control departmental storage.

```text
Department Quota : 5 GB
Quota Type       : Hard
SoftLimit        : False
```

Threshold strategy:

```text
80%
90%
100%
```

![FSRM Quotas](assets/09-fsrm-quotas.png)

---

## 10 - Backup Validation

### Backup Version

Windows Server Backup is configured with a dedicated backup target separate from the data volume.

```text
FILE01 Data
     ↓
Separate Backup Target
     ↓
Windows Server Backup
```

![File Server Backup](assets/10a-file-server-backup.png)

### Backup Content

The backup version and included items were verified before recovery testing.

```text
Backup Version : Present
Backup Target  : Verified
Backup Items   : Verified
```

![Backup Content](assets/10b-backup-content.png)

---

## 11 - Restore Validation

### SHA256 Integrity Validation

A test file was restored to an alternate location:

```text
C:\Restore-Test
```

The original and restored SHA256 hashes were compared.

```text
Original SHA256
       =
Restored SHA256
```

Result:

```text
MATCH : True
```

![Restore Hash Validation](assets/11a-restore-hash-validation.png)

### ACL Validation

NTFS permissions on the restored file were also reviewed.

```powershell
icacls "<RESTORED_FILE>"
```

Validation:

```text
File Restored    : PASS
SHA256           : PASS
ACL Preservation : PASS
```

![Restore ACL Validation](assets/11b-restore-acl-validation.png)

---

## 12 - Final Validation

### FILE01 Server Validation

Final server-side validation confirms:

```text
LanmanServer : Running
SMB Shares   : Available
FSRM         : Functional
Backup       : Available
```

![FILE01 Final Server Validation](assets/12a-file-server-final-server.png)

### Client Validation

Final validation from the Windows 11 client confirms:

```text
DNS Resolution    : Functional
TCP 445           : Reachable
Authorized Share  : Accessible
Public Share      : Accessible
Department Access : Isolated
```

![FILE01 Final Client Validation](assets/12b-file-server-final-client.png)

---

## Validation

```text
FILE01
Storage
AGDLP
SMB Shares
SMB Permissions
NTFS Permissions
Positive Access
Department Isolation
Access-Based Enumeration
FSRM
Backup
Backup Content
Restore
SHA256 Integrity
ACL Preservation
Final Server Validation
Final Client Validation
```
