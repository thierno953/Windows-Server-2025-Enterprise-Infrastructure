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

```powershell
Get-GPO -All |
Select-Object DisplayName,GpoStatus
```

```powershell
Get-GPInheritance `
    -Target "OU=Workstations,OU=Computers,OU=Diarabaka,DC=diarabaka,DC=com"
```

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

```powershell
Get-NetFirewallProfile |
Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction
```

![Security Baseline](assets/03-security-baseline-gpo.png)

```powershell
Get-MpComputerStatus |
Select-Object AntivirusEnabled,RealTimeProtectionEnabled,BehaviorMonitorEnabled
```

![Firewall Defender](assets/04-firewall-defender-effective.png)

---

## GPO Application

```powershell
gpupdate /force
gpresult /r /scope computer
```

Applied:

```text
GPO-WS-Security-Baseline
GPO-Windows11-BitLocker
GPO-Windows11-LAPS
```

![GPResult](assets/05-gpresult-applied.png)

---

## BitLocker

```powershell
Get-Tpm
manage-bde -status C:
manage-bde -protectors -get C:
```

Validated:

```text
TPM               : Ready
C:                 : Encrypted
Protection         : Enabled
TPM Protector      : Present
Recovery Password  : Present
```

![BitLocker](assets/06-bitlocker-status.png)

---

## BitLocker Recovery in AD

```powershell
$ComputerDN = (Get-ADComputer WIN11).DistinguishedName

Get-ADObject `
  -Filter 'objectClass -eq "msFVE-RecoveryInformation"' `
  -SearchBase $ComputerDN
```

```text
msFVE-RecoveryInformation
```

![BitLocker AD Recovery](assets/07-bitlocker-ad-recovery.png)

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

```powershell
Find-LapsADExtendedRights `
    -Identity "OU=Workstations,OU=Computers,OU=Diarabaka,DC=diarabaka,DC=com"
```

![Windows LAPS](assets/08-laps-gpo-settings.png)

---

## LAPS Processing

```powershell
Invoke-LapsPolicyProcessing
Get-LapsDiagnostics
```

```powershell
Get-WinEvent `
    -LogName "Microsoft-Windows-LAPS/Operational" `
    -MaxEvents 30
```

![LAPS Validation](assets/09-laps-processing.png)

> LAPS password redacted.

---

## SYSVOL / Replication

```powershell
Test-Path "\\diarabaka.com\SYSVOL"
Test-Path "\\diarabaka.com\NETLOGON"
repadmin /replsummary
dcdiag /test:sysvolcheck /test:advertising
```

```text
SYSVOL               : PASS
NETLOGON              : PASS
Replication failures : 0
```

![SYSVOL Replication](assets/10-sysvol-replication.png)

---

## GPO Backup

```powershell
$BackupPath = "C:\SysAdminToolkit\05-GroupPolicy\Backups"

Backup-GPO -All -Path $BackupPath
```

![GPO Backup](assets/11-gpo-backup.png)

---

## Post-Reboot Validation

```powershell
gpresult /r /scope computer
```

```text
Security Baseline : PASS
Firewall          : PASS
Defender          : PASS
BitLocker         : PASS
Windows LAPS      : PASS
```

![GPO Final Validation](assets/12-gpo-final-validation.png)

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
