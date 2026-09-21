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

![DNS Zones](assets/02-dns-zones.png)

---

## A / PTR Records

![A PTR](assets/03-a-ptr-records.png)

```text
Hostname -> A -> IP
IP -> PTR -> Hostname
```

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

![WIN11 DNS](assets/05-win11-dns.png)

```text
WIN11
├── DC01
└── DC02
```

No public DNS configured directly on the domain client.

---

## External Resolution

![External DNS](assets/06-external-resolution.png)

---

## DC Locator

![DC Locator](assets/07-dc-locator.png)

```text
DNS -> SRV -> DC Locator -> Domain Controller
```

---

## Kerberos

![Kerberos](assets/08-kerberos.png)

---

## DNS Health

![DNS Health](assets/09-dcdiag-dns.png)

```text
DC01 : PASS
DC02 : PASS
DNS  : PASS
```

---

## DNS Logs

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

![DNS Continuity](assets/11-dns-continuity.png)

---

## Final Validation

![DNS Final Validation](assets/12-dns-final-validation.png)

```text
Replication failures : 0
```

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
