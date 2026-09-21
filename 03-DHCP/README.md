# DHCP

## Architecture

```text
                 192.168.1.0/24
                       │
               Gateway 192.168.1.1
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
        DC01                      DC02
   192.168.1.10              192.168.1.11
   AD + DNS + DHCP           AD + DNS + DHCP
          │                         │
          └────────────┬────────────┘
                       │
              DHCP Failover 50/50
                       │
              192.168.1.100-200
                       │
                     WIN11
```

![DHCP Architecture](assets/01-dhcp-architecture.png)

---

## Role / Authorization

```powershell
Get-WindowsFeature DHCP
Get-Service DHCPServer
Get-DhcpServerInDC
Get-DhcpServerv4Binding
```

![DHCP Authorization](assets/02-dhcp-role-authorization.png)

---

## IPv4 Scope

| Parameter | Value            |
| --------- | ---------------- |
| Scope     | `192.168.1.0/24` |
| Start     | `192.168.1.100`  |
| End       | `192.168.1.200`  |
| Mask      | `255.255.255.0`  |

![DHCP Scope](assets/03-dhcp-scope.png)

---

## DHCP Options

| Option       | Value                          |
| ------------ | ------------------------------ |
| `003` Router | `192.168.1.1`                  |
| `006` DNS    | `192.168.1.10`, `192.168.1.11` |
| `015` Domain | `diarabaka.com`                |

![DHCP Options](assets/04-dhcp-options.png)

---

## Lease / Reservation

![WIN11 Reservation](assets/05-win11-lease-reservation.png)

---

## WIN11 Configuration

![WIN11 IPConfig](assets/06-win11-ipconfig.png)

```text
DHCP       : Enabled
Gateway    : 192.168.1.1
DNS 1      : 192.168.1.10
DNS 2      : 192.168.1.11
DNS suffix : diarabaka.com
```

---

## Dynamic DNS

![Dynamic DNS](assets/07-dhcp-ddns.png)

```text
WIN11
├── A
└── PTR
```

---

## DHCP Failover

![DHCP Failover](assets/08-dhcp-failover.png)

| Parameter             | Value            |
| --------------------- | ---------------- |
| Relationship          | `DHCP-DC01-DC02` |
| Mode                  | Load Balance     |
| Distribution          | `50/50`          |
| State                 | `Normal`         |
| Auto State Transition | Enabled          |
| State Switch Interval | `01:00:00`       |
| MCLT                  | Configured       |

---

## Synchronization

![DHCP Synchronization](assets/09-dhcp-synchronization.png)

---

## Failure Test

```text
DC01 unavailable
       ↓
DC02 available
       ↓
WIN11 renews lease
       ↓
DHCP remains operational
```

```powershell
ipconfig /renew
```

![DHCP Failure](assets/10-dhcp-failure-test.png)

---

## Recovery

![DHCP Recovery](assets/11-dhcp-recovery.png)

```text
State : Normal
```

---

## Final Validation

![DHCP Final Validation](assets/12-dhcp-final-validation.png)

### Validation

| Control          | Status |
| ---------------- | :----: |
| DHCP Roles       |   ✅   |
| AD Authorization |   ✅   |
| Scope            |   ✅   |
| Options          |   ✅   |
| Reservation      |   ✅   |
| Dynamic DNS      |   ✅   |
| Failover 50/50   |   ✅   |
| Synchronization  |   ✅   |
| Failure Test     |   ✅   |
| Recovery         |   ✅   |

**Status:** ✅ `VALIDATED`
