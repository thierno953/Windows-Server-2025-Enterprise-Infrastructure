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

![GPO Links](assets/01-gpo-links.png)

---

## GPO Scope

![GPO Scope](assets/02-gpo-inventory-scope.png)

---

## Security Baseline

```text
Windows Firewall
Microsoft Defender
Real-Time Protection
Behavior Monitoring
IOAV
Cloud Protection
Windows Update
```

![Security Baseline](assets/03-security-baseline-gpo.png)

![Firewall Defender](assets/04-firewall-defender-effective.png)

---

## GPO Application

![GPResult](assets/05-gpresult-applied.png)

Applied:

```text
GPO-WS-Security-Baseline
GPO-Windows11-BitLocker
GPO-Windows11-LAPS
```

---

## BitLocker

![BitLocker](assets/06-bitlocker-status.png)

Validated:

```text
TPM               : Ready
C:                 : Encrypted
Protection         : Enabled
TPM Protector      : Present
Recovery Password  : Present
```

---

## BitLocker Recovery in AD

![BitLocker AD Recovery](assets/07-bitlocker-ad-recovery.png)

```text
msFVE-RecoveryInformation
```

> Recovery key redacted.

---

## Windows LAPS

| Setting                     | Value            |
| --------------------------- | ---------------- |
| Backup                      | Active Directory |
| Password Length             | 14+              |
| Password Age                | 30 days          |
| Encryption                  | Enabled          |
| Post-Authentication Actions | Configured       |

![Windows LAPS](assets/08-laps-gpo-settings.png)

---

## LAPS Processing

![LAPS Validation](assets/09-laps-processing.png)

> LAPS password redacted.

---

## SYSVOL / Replication

![SYSVOL Replication](assets/10-sysvol-replication.png)

```text
SYSVOL               : PASS
NETLOGON              : PASS
Replication failures : 0
```

---

## GPO Backup

![GPO Backup](assets/11-gpo-backup.png)

---

## Post-Reboot Validation

![GPO Final Validation](assets/12-gpo-final-validation.png)

```text
Security Baseline : PASS
Firewall          : PASS
Defender          : PASS
BitLocker         : PASS
Windows LAPS      : PASS
```

### Validation

| Control             | Status |
| ------------------- | :----: |
| GPO Scope           |   ✅   |
| Security Baseline   |   ✅   |
| Firewall / Defender |   ✅   |
| BitLocker           |   ✅   |
| AD Recovery         |   ✅   |
| Windows LAPS        |   ✅   |
| SYSVOL              |   ✅   |
| Replication         |   ✅   |
| GPO Backup          |   ✅   |
| Post-Reboot         |   ✅   |

**Status:** ✅ `VALIDATED`
