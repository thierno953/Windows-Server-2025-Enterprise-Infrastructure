# DNS

## Architecture

```text
                    WIN11
                      │
                   DNS
                      │
             ┌────────┴────────┐
             ▼                 ▼
           DC01              DC02
        AD DS + DNS       AD DS + DNS
             │                 │
             └────────┬────────┘
                      │
                AD Replication
                      │
      ┌───────────────┼────────────────┐
      ▼               ▼                ▼
diarabaka.com   _msdcs.diarabaka.com   Reverse DNS
```

![DNS Architecture](assets/01-dns-architecture.png)

---

## DNS Zones

```text
diarabaka.com
_msdcs.diarabaka.com
1.168.192.in-addr.arpa
```

```powershell
Get-DnsServerZone |
Select-Object ZoneName,ZoneType,IsDsIntegrated,DynamicUpdate,ReplicationScope
```

![DNS Zones](assets/02-dns-zones.png)

---

## A / PTR Records

```powershell
Resolve-DnsName dc01.diarabaka.com
```

```text
Hostname → A → IP
IP → PTR → Hostname
```

![A PTR](assets/03-a-ptr-records.png)

---

## Active Directory SRV

```powershell
Resolve-DnsName "_ldap._tcp.dc._msdcs.diarabaka.com" -Type SRV
Resolve-DnsName "_kerberos._tcp.diarabaka.com" -Type SRV
Resolve-DnsName "_ldap._tcp.gc._msdcs.diarabaka.com" -Type SRV
```

![LDAP SRV](assets/04-ldap-srv.png)

---

## WIN11 DNS

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

```text
WIN11
├── DC01
└── DC02
```

No public DNS configured directly on the domain client.

![WIN11 DNS](assets/05-win11-dns.png)

---

## External Resolution

```powershell
Resolve-DnsName www.microsoft.com
```

![External DNS](assets/06-external-resolution.png)

---

## DC Locator

```powershell
nltest /dsgetdc:diarabaka.com
```

```text
DNS → SRV → DC Locator → Domain Controller
```

![DC Locator](assets/07-dc-locator.png)

---

## Kerberos

```powershell
klist
```

![Kerberos](assets/08-kerberos.png)

---

## DNS Health

```powershell
dcdiag /test:dns
```

```text
DC01 : PASS
DC02 : PASS
DNS  : PASS
```

![DNS Health](assets/09-dcdiag-dns.png)

---

## DNS Logs

```powershell
Get-WinEvent -LogName "DNS Server" -MaxEvents 20
```

![DNS Logs](assets/10-dns-logs.png)

---

## Redundancy / Failure Test

```text
DC01 unavailable
       ↓
DC02 available
       ↓
DNS resolution continues
       ↓
DC Locator remains functional
```

```powershell
Resolve-DnsName dc01.diarabaka.com -Server 192.168.1.11
```

![DNS Continuity](assets/11-dns-continuity.png)

---

## Final Validation

```powershell
repadmin /replsummary
```

```text
Replication failures : 0
```

![DNS Final Validation](assets/12-dns-final-validation.png)

### Validation

| Control                 | Status |
| ----------------------- | :----: |
| AD-Integrated DNS       |   ✅   |
| Forward / Reverse Zones |   ✅   |
| A / PTR                 |   ✅   |
| LDAP / Kerberos SRV     |   ✅   |
| WIN11 DNS               |   ✅   |
| External Resolution     |   ✅   |
| DC Locator              |   ✅   |
| DCDIAG                  |   ✅   |
| DNS Redundancy          |   ✅   |
| Failure / Recovery      |   ✅   |

**Status:** ✅ `VALIDATED`
