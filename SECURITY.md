# 🛡️ Security Policy & Vulnerability Management

Enterprise PII Guardrails Studio is engineered for zero-trust, high-assurance security environments. We take vulnerability reports seriously and operate an aggressive, structured vulnerability remediation protocol.

---

## 📦 Supported Versions

Only the current and immediately preceding minor release branches receive official security patches:

| Version | Supported | Security Patch Status |
| :--- | :---: | :--- |
| `2.0.x` | ✅ Yes | **Active Support** (P0 vulnerabilities patched in <7 days) |
| `1.9.x` | ⚠️ Limited | Critical security updates only |
| `< 1.9.0` | ❌ No | Unsupported. Users must upgrade to 2.0.x |

---

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability, flaw, or potential zero-egress bypass within Enterprise PII Guardrails, **DO NOT** create a public GitHub issue.

Please submit your report through one of the following private channels:
* **GitHub Private Security Advisory**: [Open Security Advisory](https://github.com/piiguardrails/piiguardrails/security/advisories/new)
* **Encrypted Security Email**: `security@piiguardrails.com`

### Report Requirements
To help our security engineering team triage and verify your finding promptly, please include:
1. **Description**: Clear explanation of the vulnerability and its potential impact.
2. **Reproduction Steps**: Step-by-step instructions or minimal proof-of-concept (PoC) payload.
3. **Environment**: Operating system, architecture (x86_64, aarch64), runtime mode (Standalone Binary or Docker container).
4. **Affected Component**: Specific API endpoint, parser, or cryptographic vault module.

---

## ⏱️ Response & Remediation SLAs

Our engineering team adheres to the following security resolution SLAs:

| Severity (CVSS v3.1) | Initial Response | Triage & Reproduction | Patch & Hotfix Release |
| :--- | :---: | :---: | :---: |
| **Critical (9.0 - 10.0)** | `< 24 Hours` | `< 48 Hours` | **`< 7 Days`** |
| **High (7.0 - 8.9)** | `< 24 Hours` | `< 72 Hours` | **`< 14 Days`** |
| **Medium (4.0 - 6.9)** | `< 48 Hours` | `< 5 Business Days`| **`< 30 Days`** |
| **Low (0.1 - 3.9)** | `< 72 Hours` | Next Minor Release | Next Minor Release |

---

## 🔒 Security Principles of the Architecture

* **Zero Cloud Egress**: The software runtime executes 100% inside your VPC with zero outbound telemetry, health beacons, or cloud lookups.
* **Encrypted at Rest**: All sensitive configurations, token mappings, and audit logs are stored in SQLCipher using hardware-accelerated 256-bit AES-CBC encryption with per-page HMAC-SHA512 integrity.
* **Non-Default Credentials**: Production containers strictly terminate if non-default administrative passwords (`GUI_PASSWORD`) or database passphrases are omitted.
