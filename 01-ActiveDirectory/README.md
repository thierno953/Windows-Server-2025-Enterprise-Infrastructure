# ACTIVE DIRECTORY

## Architecture

![AD Architecture](assets/01-architecture-ou.png)

---

## PowerShell Automation

```text
C:\SysAdminToolkit\02-ActiveDirectory
├── Data\Users.csv
├── Logs\
├── Reports\
├── 01-Create-AD-OUs.ps1
├── 02-Create-Users.ps1
├── 03-Create-Groups.ps1
├── 04-Assign-Users-To-Groups.ps1
└── 05-Helpdesk-UserManagement.ps1
```

- 20 users provisioned from CSV
- automatic OU placement
- security groups
- department membership
- account lifecycle
- Helpdesk operations

![PowerShell Automation](assets/02-powershell-preview.png)

---

## Users and Groups

![AD Users](assets/03-utilisateurs-ad.png)

![AD Groups](assets/04-groupes-membership.png)

---

## Secure Administration

```text
Standard User
      ≠
Administrative Account
```

Helpdesk operations:

```powershell
.\05-Helpdesk-UserManagement.ps1 -Action ResetPassword -Username jdupont
.\05-Helpdesk-UserManagement.ps1 -Action Unlock -Username jdupont
.\05-Helpdesk-UserManagement.ps1 -Action Disable -Username jdupont
.\05-Helpdesk-UserManagement.ps1 -Action Enable -Username jdupont
```

![Helpdesk Delegation](assets/05-delegation-helpdesk.png)

---

## Password & Lockout Policy

| Control               | Value      |
| --------------------- | ---------- |
| Minimum length        | 12         |
| History               | 24         |
| Complexity            | Enabled    |
| Maximum age           | 180 days   |
| Minimum age           | 1 day      |
| Lockout threshold     | 5 attempts |
| Lockout duration      | 15 minutes |
| Reversible encryption | Disabled   |

![Password Policy](assets/06-password-lockout-policy.png)

---

## FSMO / Global Catalog

```text
DC01
├── PDC Emulator
├── RID Master
└── Infrastructure Master

DC02
├── Schema Master
└── Domain Naming Master

Global Catalog
├── DC01
└── DC02
```

![FSMO](assets/07-fsmo-global-catalog.png)

---

## Replication

![AD Replication](assets/08-replication.png)

```text
Replication failures : 0
```

---

## Health Check

![AD Health](assets/09-dcdiag-health.png)

```text
DC01        : PASS
DC02        : PASS
Advertising : PASS
Services    : PASS
SysVolCheck : PASS
NetLogons   : PASS
DNS         : PASS
```

---

## Backup / Restore

- System State backup
- separate backup target
- restore tested

![System State Backup](assets/10-system-state-backup.png)

### Validation

| Control             | Status |
| ------------------- | :----: |
| OU Structure        |   ✅   |
| 20 Users            |   ✅   |
| Groups              |   ✅   |
| Helpdesk Delegation |   ✅   |
| Password Policy     |   ✅   |
| FSMO / GC           |   ✅   |
| Replication         |   ✅   |
| DCDIAG              |   ✅   |
| Backup / Restore    |   ✅   |

**Status:** ✅ `VALIDATED`
