# TASK23 - LDAPS Configuration and Validation

## Overview

Implemented and validated **LDAPS (LDAP over SSL/TLS)** for the `diarabaka.com` Active Directory environment.

LDAPS provides encrypted LDAP communication between domain clients and Domain Controllers.

This validation focuses on:

- Domain Controller certificate
- Server Authentication capability
- Certificate trust
- LDAPS over TCP 636
- Successful SSL/TLS LDAP connection

---

## 01 - Domain Controller Certificate

![LDAPS Certificate](./assets/01-ldaps-certificate-gui.png)

The Domain Controller certificate was verified using the Windows Certificates MMC console.

Path:

```text
Certificates (Local Computer)
└── Personal
    └── Certificates
```

The certificate confirms:

```text
Issued To        : WIN2025-DC01.diarabaka.com
Issued By        : Internal Enterprise CA
Private Key      : Present
Server Auth      : Enabled
Certificate      : Valid
```

The certificate includes the required **Server Authentication** purpose for secure LDAP communication.

---

## 02 - LDAPS Connection Validation

![LDAPS Connection](./assets/02a-ldaps-ldp-success.png)

![LDAPS Connection](./assets/02b-ldaps-ldp-success.png)

![LDAPS Connection](./assets/02c-ldaps-ldp-success.png)

![LDAPS Connection](./assets/02d-ldaps-ldp-success.png)

![LDAPS Connection](./assets/02e-ldaps-ldp-success.png)

![LDAPS Connection](./assets/02f-ldaps-ldp-success.png)

LDAPS connectivity was validated using:

```text
ldp.exe
```

Connection settings:

```text
Server : WIN2025-DC01.diarabaka.com
Port   : 636
SSL    : Enabled
```

A successful connection confirms that the Domain Controller accepts secure LDAP connections over SSL/TLS.

---

## Architecture

```text
Windows 11 Client
       │
       │ LDAPS
       │ TCP 636
       ▼
WIN2025-DC01
       │
       ├── Active Directory Domain Services
       ├── Domain Controller Certificate
       ├── Server Authentication
       └── SSL/TLS
       │
       ▼
Active Directory
diarabaka.com
```

---

## Security Flow

```text
Enterprise CA
     ↓
Domain Controller Certificate
     ↓
Server Authentication
     ↓
TLS
     ↓
LDAPS TCP 636
     ↓
Encrypted LDAP Communication
```

---

## Validation

```text
Domain Controller Certificate : Present
Certificate Validity          : Valid
Private Key                    : Present
Server Authentication         : Enabled
LDAPS Port                     : 636
SSL/TLS Connection            : Successful
LDAPS                          : VALIDATED
```
