# 🏰 Threat Model & Security Architecture

This document formalizes the **STRIDE Threat Model** and trust boundaries for **Enterprise PII Guardrails Studio**.

---

## 🌐 System Boundaries & Trust Zones

```text
[ External Clients / Web UI ]
             │  (Zone 1: Untrusted Input / JSON Payloads)
             ▼
   [ FastAPI Gateway Ingress ]  <─── Strict Rate Limiting & Auth Check
             │
             ├─── [ LRU In-Memory Auth Cache ] (Zone 2: Memory Cache)
             ├─── [ Multi-Tier Recognition Engine ] (Zone 3: Core CPU Execution)
             │          │
             │          ├── Regex Recognizers + Checksums
             │          └── Context-Aware NER Engine
             │
             ├─── [ Reversible Token Mapping Vault ]
             │          │
             │          └── SQLCipher 256-bit AES-CBC (Zone 4: Encrypted Storage)
             │
             ▼  (Zone 5: Sanitized Egress Payload)
[ External LLM Provider (OpenAI, Anthropic, Bedrock) ]
```

---

## 🎯 STRIDE Threat Analysis & Mitigations

| STRIDE Category | Potential Threat | Architectural Mitigation |
| :--- | :--- | :--- |
| **Spoofing (S)** | Unauthorized client impersonating admin to view token mappings or disable rules. | **API Key Hashing & Session Isolation**: Admin endpoints require valid session tokens or high-entropy API keys. Keys are validated in constant time and salted using PBKDF2/SHA-256. |
| **Tampering (T)** | Attacker modifying on-disk database to alter audit logs or inject malicious regex. | **SQLCipher AES-CBC + HMAC-SHA512**: Every 4096-byte database page includes an HMAC-SHA512 message authentication code. Any bit-level disk tampering corrupts page decryption and terminates database access safely. |
| **Repudiation (R)** | Rogue administrator denies exporting sensitive tokens or modifying audit profiles. | **Immutable Audit Trails**: Every masking operation, rule modification, and configuration export is cryptographically recorded in the local append-only audit log with microsecond timestamps and client IP addresses. |
| **Information Disclosure (I)** | PII leakage into third-party LLM APIs or plaintext log files. | **Deterministic Tokenization Gateway**: Input text is scanned and replaced with synthetically generated placeholder tokens (`<PERSON_1>`, `<SSN_1>`). Reversible mappings never leave internal encrypted memory and database tables. |
| **Denial of Service (D)** | Regular Expression Denial of Service (ReDoS) via catastrophic backtracking payloads. | **Bounded Execution & Input Length Enforcement**: Custom regex patterns undergo compile-time safety validation. Built-in patterns use atomic groups and possess linear-time execution characteristics. Maximum payload length is strictly enforced. |
| **Elevation of Privilege (E)** | Attacker utilizing unmasking endpoint to retrieve unauthorized patient data. | **Role-Based Access Control (RBAC)**: The `/unmask` endpoint requires matching session keys or administrator-level credentials. Public demo sandboxes run with read-only ephemeral storage overlays. |

---

## 🛡️ Network Ingress / Egress Profile

* **Inbound Traffic**: TCP port `8000` (or user-defined port). Accepts HTTP/REST payloads (`/mask`, `/unmask`, `/health`, `/api/*`).
* **Outbound Traffic**: **ZERO (0) outbound network connections by default.**
  - No external phone-home telemetry.
  - No remote model downloading.
  - Outbound connections are initiated ONLY if an administrator explicitly configures an external SIEM endpoint (Splunk HEC or Datadog Intake API) in Settings.
