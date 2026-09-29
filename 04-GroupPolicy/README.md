# GROUP POLICY

## Architecture

```text
DIARABAKA.COM
│
└── OU=Diarabaka
    └── Computers
        └── Workstations
            └── WIN11
                │
                ├── GPO-WS-Security-Baseline
                ├── GPO-Windows11-BitLocker
                └── GPO-Windows11-LAPS
```

---

## 01 - GPO Inventory

![GPO Inventory](assets/01-gpo-inventory.png)

```text
GPO-WS-Security-Baseline
GPO-Windows11-BitLocker
GPO-Windows11-LAPS
Default Domain Policy
```

---

## 02 - OU and GPO Links

![GPO OU Links](assets/02-gpo-ou-links.png)

Target:

```text
CN=WIN11
OU=Workstations
OU=Computers
OU=Diarabaka
DC=diarabaka,DC=com
```

---

## 03 - Applied Group Policies

![GPResult](assets/03-gpresult-applied-gpos.png)

Applied:

```text
GPO-WS-Security-Baseline
GPO-Windows11-BitLocker
GPO-Windows11-LAPS
Default Domain Policy
```

---

## 04 - Windows Firewall

![Firewall Baseline](assets/04-firewall-baseline.png)

Validated:

```text
Domain Profile  : Enabled
Private Profile : Enabled
Public Profile  : Enabled
```

---

## 05 - Microsoft Defender

![Defender Baseline](assets/05-defender-baseline.png)

Validated:

```text
Antivirus                  : Enabled
Real-Time Protection       : Enabled
Antispyware                : Enabled
Behavior Monitoring        : Enabled
IOAV Protection            : Enabled
```

---

## 06 - BitLocker and TPM

![BitLocker TPM](assets/06-bitlocker-tpm.png)

Validated:

```text
TPM Present          : True
TPM Ready            : True
TPM Enabled          : True
TPM Activated        : True

Volume C:            : Fully Encrypted
Protection           : On
Encryption           : 100%
Encryption Method    : XTS-AES
TPM Protector        : Present
Recovery Protector   : Present
```

> BitLocker recovery password is not exposed.

---

## 07 - BitLocker Recovery in Active Directory

![BitLocker AD Recovery](assets/07-bitlocker-ad-recovery.png)

Validated:

```text
msFVE-RecoveryInformation
```

> Recovery information verified in Active Directory. Recovery secrets are not published.

---

## 08 - Windows LAPS

![Windows LAPS](assets/08-windows-laps.png)

| Setting             | Value            |
| ------------------- | ---------------- |
| Backup Directory    | Active Directory |
| Password Length     | 14+              |
| Password Age        | 30 days          |
| Password Encryption | Enabled          |
| Policy Processing   | Enabled          |

```text
Windows LAPS
     ↓
WIN11
     ↓
Password Rotation
     ↓
Active Directory Backup
```

> LAPS password is redacted.

---

## 09 - SYSVOL and Active Directory Replication

![SYSVOL Replication](assets/09-sysvol-gpo-replication.png)

Validated:

```text
SYSVOL               : Available
NETLOGON              : Available
AD Replication        : Healthy
Replication Failures  : 0
```

---

## 10 - Final Group Policy Validation

![GPO Final Validation](assets/10-gpo-final-validation.png)

```text
GPO Application      : PASS
Security Baseline    : PASS
Windows Firewall     : PASS
Microsoft Defender   : PASS
BitLocker            : PASS
Windows LAPS         : PASS
SYSVOL               : PASS
AD Replication       : PASS
Post-Reboot          : PASS
```

---

## Validation

```text
GPO Inventory
OU / GPO Links
GPO Application
Windows Firewall
Microsoft Defender
BitLocker / TPM
BitLocker AD Recovery
Windows LAPS
SYSVOL / Replication
Post-Reboot Validation
```
