# Enterprise PII Guardrails Node for n8n

<p align="center">
  <a href="https://www.npmjs.com/package/n8n-nodes-piiguardrails"><img src="https://img.shields.io/npm/v/n8n-nodes-piiguardrails?color=00c853&style=for-the-badge&logo=npm" alt="npm version" /></a>
  <a href="https://nodejs.org"><img src="https://img.shields.io/badge/Node.js-%3E%3D%2018.0.0-339933?style=for-the-badge&logo=node.js" alt="Node.js version" /></a>
  <a href="https://n8n.io"><img src="https://img.shields.io/badge/n8n-community--node-EA4B71.svg?style=for-the-badge&logo=n8n" alt="n8n community node" /></a>
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/License-Proprietary-7c4dff.svg?style=for-the-badge" alt="License" /></a>
  <a href="https://piiguardrails.com"><img src="https://img.shields.io/badge/Zero--Data--Retention-Guaranteed-00e676?style=for-the-badge&logo=shield" alt="Zero Data Retention" /></a>
  <a href="https://piiguardrails.com"><img src="https://img.shields.io/badge/Compliance-HIPAA%20%7C%20GDPR%20%7C%20PCI--DSS-ff9100?style=for-the-badge" alt="Compliance Standards" /></a>
</p>

<p align="center">
  <strong>Zero-leakage data privacy, deterministic PII masking, cryptographic token restoration, and statutory compliance guardrails for AI/LLM workflows in n8n.</strong><br>
  <em>Developed and maintained by <a href="https://piiguardrails.com">piiguardrails.com</a>.</em>
</p>

---

## 📑 Table of Contents

- [Overview & Architecture](#-overview--architecture)
- [The Problem We Solve](#-the-problem-we-solve)
- [Key Operations](#-key-operations)
  - [1. Mask (Sanitize Prompt)](#1-mask-sanitize-prompt)
  - [2. Unmask (Restore Output)](#2-unmask-restore-output)
  - [3. Scan / Audit (Detect Only)](#3-scan--audit-detect-only)
- [Supported Entities & Compliance Catalog](#-supported-entities--compliance-catalog)
- [Node Configuration & Parameter Reference](#-node-configuration--parameter-reference)
- [Quick Start: 60-Second Instant Sandbox](#-quick-start-60-second-instant-sandbox)
- [Production On-Premises & Private Cloud Deployment](#-production-on-premises--private-cloud-deployment)
- [Pre-Built Workflow Templates & One-Click Import](#-pre-built-workflow-templates--one-click-import)
- [Installation Guide](#-installation-guide)
- [Troubleshooting & Diagnostic FAQ](#-troubleshooting--diagnostic-faq)
- [Security & Zero Data Retention Guarantees](#-security--zero-data-retention-guarantees)
- [Intellectual Property & Licensing](#-intellectual-property--licensing)

---

## 🔒 Overview & Architecture

The **Enterprise PII Guardrails** connector acts as a deterministic privacy firewall between your sensitive business systems (CRMs, databases, email triggers, webhooks) and third-party Large Language Models (OpenAI, Anthropic Claude, Google Gemini, Mistral, Ollama).

Instead of exposing customer identities, financial instruments, and medical records to external AI providers, this node automatically intercepts, redacts, and cryptographically isolates sensitive entities before they leave your perimeter, and flawlessly restores them into the LLM's generated response.

```text
[Incoming Trigger / CRM / Webhook]
       │
       ▼ (Contains sensitive PII: Alice Smith, SSN, Credit Card, Medical ID)
[🛡️ PII Guardrails: Mask]
       │
       ├──► Generates cryptographically isolated token mapping in memory
       ▼ (Sanitized text with deterministic tokens: [HUMAN_NAME_1], [CREDIT_CARD_1])
[🤖 AI / LLM Agent (OpenAI / Claude / Gemini / Ollama)]
       │
       ▼ (Model processes reasoning safely using sanitized placeholder tokens)
[🔓 PII Guardrails: Unmask]
       │
       ├──► Recombines mapping dictionary to restore real customer data
       ▼ (Reconstructed output with 100% data fidelity)
[Slack / Email / CRM / Database Delivery]
```

---

## 🚨 The Problem We Solve

When building automated AI workflows in n8n, organizations encounter severe regulatory and legal hurdles:

| Challenge | Without PII Guardrails | With Enterprise PII Guardrails |
| :--- | :--- | :--- |
| **Regulatory Compliance** | Violates HIPAA §164.514, GDPR Art 4/9/32, PCI-DSS v4.0 Req 3, and India DPDP Act 2023. | **100% Compliant**: Sensitive entities never leave your infrastructure. |
| **Data Retention by LLM Vendors** | Customer names, SSNs, and health records get stored in vendor training/eval logs. | **Zero Exposure**: LLM vendors only receive opaque tokens like `[HUMAN_NAME_1]`. |
| **Destructive Redaction** | Traditional redactors replace PII with `[REDACTED]`, destroying the LLM's context and ability to reply personally. | **Deterministic Pseudonymization**: Consistent tokens preserve grammatical agreement and context. |
| **Bi-Directional Restoration** | Generic scrubbers cannot restore the original data into the model's generated answer. | **Lossless Token Restoration**: Automated unmasking matches original values flawlessly. |

---

## ⚡ Key Operations

### 1. Mask (Sanitize Prompt)

Scans input text or structured JSON payloads, detects all sensitive entities, replaces them with deterministic placeholders, and outputs the sanitized payload alongside an isolated token mapping.

#### Sample Input
```text
Hello Support, my name is Alice Smith (email: alice.smith@healthcare.corp, cell: 415-555-2671).
Please process insurance claim for Patient ID MRN-998234 using Visa card 4111-2222-3333-4444.
```

#### Output Payload Structure
```json
{
  "masked_text": "Hello Support, my name is [HUMAN_NAME_1] (email: [EMAIL_ADDRESS_1], cell: [PHONE_NUMBER_1]). Please process insurance claim for Patient ID [MEDICAL_RECORD_NUMBER_1] using Visa card [CREDIT_CARD_NUMBER_1].",
  "mapping": {
    "[HUMAN_NAME_1]": "Alice Smith",
    "[EMAIL_ADDRESS_1]": "alice.smith@healthcare.corp",
    "[PHONE_NUMBER_1]": "415-555-2671",
    "[MEDICAL_RECORD_NUMBER_1]": "MRN-998234",
    "[CREDIT_CARD_NUMBER_1]": "4111-2222-3333-4444"
  },
  "interception_counts": {
    "HUMAN_NAME": 1,
    "EMAIL_ADDRESS": 1,
    "PHONE_NUMBER": 1,
    "MEDICAL_RECORD_NUMBER": 1,
    "CREDIT_CARD_NUMBER": 1
  },
  "entity_count": 5
}
```

---

### 2. Unmask (Restore Output)

Accepts the generated response from an upstream AI/LLM node containing placeholder tokens, matches them against the preserved `mapping` dictionary, and reconstructs the final text with original data intact.

#### Sample Input to Unmask
* **Generated Text from LLM**:
  ```text
  Dear [HUMAN_NAME_1], we have confirmed receipt of claim [MEDICAL_RECORD_NUMBER_1].
  A receipt has been dispatched to [EMAIL_ADDRESS_1], and the balance was charged to card [CREDIT_CARD_NUMBER_1].
  ```
* **Mapping Dictionary**: Wired directly from the upstream Mask node (`{{ $('PII Guardrails: Mask').item.json.mapping }}`).

#### Output Payload Structure
```json
{
  "unmasked_text": "Dear Alice Smith, we have confirmed receipt of claim MRN-998234. A receipt has been dispatched to alice.smith@healthcare.corp, and the balance was charged to card 4111-2222-3333-4444."
}
```

---

### 3. Scan / Audit (Detect Only)

Passively audits payloads for sensitive PII, compliance violations, and confidentiality leaks without mutating the content. Ideal for automated quality assurance, DLP (Data Loss Prevention) triggers, and security routing.

#### Output Payload Structure
```json
{
  "has_pii": true,
  "entity_count": 3,
  "findings": [
    { "type": "EMAIL_ADDRESS", "value": "alice.smith@healthcare.corp", "start": 47, "end": 74 },
    { "type": "PHONE_NUMBER", "value": "415-555-2671", "start": 82, "end": 94 },
    { "type": "CREDIT_CARD_NUMBER", "value": "4111-2222-3333-4444", "start": 164, "end": 183 }
  ]
}
```

---

## 📋 Supported Entities & Compliance Catalog

Enterprise PII Guardrails features an enterprise-grade hybrid detection engine combining contextual machine learning NER, deterministic pattern recognition, Shannon entropy analysis, and statutory validation algorithms:

| Category | Entity Type | Generated Token | Statutory / Regulatory Mapping | Validation Method |
| :--- | :--- | :--- | :--- | :--- |
| **Personal Identity** | Full Names / Surnames | `[HUMAN_NAME_N]` | GDPR Art 4(1), CCPA/CPRA, HIPAA Safe Harbor §164.514 | Multi-Token Contextual NER |
| **Contact Data** | Email Addresses | `[EMAIL_ADDRESS_N]` | GDPR, CCPA, TCPA, DPDP Act 2023 | RFC 5322 Compliant Regex |
| **Telephony** | Phone & Mobile Numbers | `[PHONE_NUMBER_N]` | TCPA, HIPAA, GDPR, DPDP Act | E.164 + Country-Specific Regex |
| **National IDs** | US Social Security Number | `[US_SSN_N]` | HIPAA, GLBA, PCI-DSS | Area/Group Format + SSN Validator |
| **Financial** | Credit / Debit Cards | `[CREDIT_CARD_NUMBER_N]` | PCI-DSS v4.0 Req 3, GLBA | Luhn Algorithm (MOD 10) Checksum |
| **Financial** | International Bank Account (IBAN) | `[BANK_ACCOUNT_N]` | GLBA, SEPA, Financial Privacy Act | ISO 13616 MOD 97 Validation |
| **Healthcare** | Medical Record Number (MRN) | `[MEDICAL_RECORD_NUMBER_N]` | HIPAA Safe Harbor 18 Identifiers | Clinical Identifier Rules |
| **Healthcare** | Health Insurance Policy / NPI | `[HEALTH_PLAN_ID_N]` | HIPAA Compliance, HITECH Act | CMS National Provider Format |
| **Cybersecurity** | API Secrets & Private Keys | `[API_SECRET_KEY_N]` | SOC 2 Type II, ISO 27001 | High-Entropy + Header Signatures |
| **Network** | IPv4 & IPv6 Addresses | `[IP_ADDRESS_N]` | GDPR (Recital 30 Online Identifiers) | Octet & Subnet Boundary Verification |
| **Cryptocurrency** | Bitcoin / Ethereum Addresses | `[CRYPTO_WALLET_N]` | FinCEN, BSA Regulations | Base58 / Keccak-256 Checksum |

---

## 🛠️ Node Configuration & Parameter Reference

### Node Parameters

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| **Operation** | `options` | Yes | `mask` | Select operation: `Mask (Sanitize Prompt)`, `Unmask (Restore Output)`, or `Scan / Audit (Detect Only)`. |
| **Text to Process** | `string` | Yes | `={{ $json.text }}` | The input text expression or variable containing sensitive data to be sanitized or audited. |
| **Token Mapping** | `json` | Yes *(Unmask only)* | `={{ $json.mapping }}` | JSON object containing placeholder-to-original mappings emitted by an upstream Mask node. |

### Credential Configuration (`piiGuardrailsApi`)

| Field | Type | Required | Placeholder / Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| **Base URL** | `string` | Yes | `http://localhost:8000` | Target URL of your server instance. Use `https://demo.piiguardrails.com` for instant sandbox testing, or `http://localhost:8000` (`http://host.docker.internal:8000`) for on-premise Docker. |
| **API Key** | `string (password)`| Yes | *(Empty)* | Your Enterprise API key or instant sandbox key (`demo_...`). |

---

## 🚀 Quick Start: 60-Second Instant Sandbox

Test Enterprise PII Guardrails immediately in n8n without installing a local server:

1. **Get Sandbox Key**:
   * Open **[https://demo.piiguardrails.com](https://demo.piiguardrails.com)** in your browser.
   * Click **`[📋 Copy Key]`** in the top navigation header to copy your sandbox key.
2. **Configure Credentials in n8n**:
   * In n8n, navigate to **Credentials** ➔ **New Credential** ➔ search for **Enterprise PII Guardrails API**.
   * Set **Base URL**: `https://demo.piiguardrails.com`
   * Set **API Key**: Paste your copied sandbox key (`demo_...`)
   * Click **Save**.
3. **Execute Test**:
   * Add the **PII Guardrails** node to any workflow, select **Mask**, enter sample text containing names and emails, and hit **Test step**.

---

## 🏢 Production On-Premises & Private Cloud Deployment

For air-gapped, sovereign, or private corporate VPC deployments (HIPAA/GDPR on-premise compliance):

### Run via Docker
```bash
docker run -d \
  --name pii-guardrails \
  -p 8000:8000 \
  -e ACCEPT_LICENSE=true \
  -v pii_data:/app/data \
  --restart unless-stopped \
  piiguardrails/enterprise-pii-guardrail:latest
```

### Docker Compose
```yaml
services:
  pii-guardrails:
    image: piiguardrails/enterprise-pii-guardrail:latest
    container_name: pii-guardrails
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      - ACCEPT_LICENSE=true
    volumes:
      - pii_data:/app/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  pii_data:
```

> [!TIP]
> **Containerized n8n Networking Note**:  
> If n8n runs inside Docker on the same host machine as the Guardrails server, do not use `http://localhost:8000` (which targets n8n's own container). Instead, set **Base URL** to:
> - **Docker Desktop (Mac / Windows)**: `http://host.docker.internal:8000`
> - **Podman (Linux / Windows)**: `http://host.containers.internal:8000`
> - **Docker Compose**: `http://pii-guardrails:8000` (using service name on shared network).

---

## 📦 Pre-Built Workflow Templates & One-Click Import

We provide ready-to-run workflow templates that demonstrate an end-to-end PII-safe LLM pipeline:

* **Template File**: [`workflows/Local_PII_Safe_LLM_Pipeline.json`](workflows/Local_PII_Safe_LLM_Pipeline.json)
* **Raw GitHub URL (Direct n8n Import)**:
  ```text
  https://raw.githubusercontent.com/piiguardrails/piiguardrails/main/workflows/Local_PII_Safe_LLM_Pipeline.json
  ```

### How to Import into n8n:
* **Option A (Instant Paste)**: Open [`workflows/Local_PII_Safe_LLM_Pipeline.json`](workflows/Local_PII_Safe_LLM_Pipeline.json), copy the entire JSON, click anywhere on your n8n workflow canvas, and press **`Ctrl + V`** (**`Cmd + V`** on Mac).
* **Option B (Import from URL)**: In your n8n canvas top-right menu (`...`), select **Import from URL**, paste the raw GitHub URL above, and click **Import**.

---

## 🔧 Installation Guide

### Method 1: Via n8n Community Nodes Settings (Recommended)
1. In your self-hosted n8n instance, click **Settings** (gear icon in left sidebar).
2. Select **Community Nodes** in the menu.
3. Click **Install a community node**.
4. In the package field, enter:
   ```text
   n8n-nodes-piiguardrails
   ```
5. Check the box agreeing to community terms and click **Install**.

### Method 2: Via Container CLI
For containerized n8n deployments:
```bash
# Docker:
docker exec -u node -it <n8n-container-name> npm install n8n-nodes-piiguardrails

# Podman:
podman exec -u node -it <n8n-container-name> npm install n8n-nodes-piiguardrails
```
Restart the container after installation to refresh the node registry.

---

## 🔍 Troubleshooting & Diagnostic FAQ

### 1. `Request failed with status code 403`
* **Cause**: Missing, invalid, or expired API Key in credentials.
* **Resolution**: If using the hosted sandbox, verify your key starts with `demo_` and was copied fresh from [https://demo.piiguardrails.com](https://demo.piiguardrails.com). If using on-premise, verify the key was generated in your Studio dashboard (`http://localhost:8000/ui/`).

### 2. `connect ECONNREFUSED 127.0.0.1:8000`
* **Cause**: n8n is running inside a container and attempting to connect to its own container loopback rather than the host machine.
* **Resolution**: Change **Base URL** in credentials from `http://localhost:8000` to `http://host.docker.internal:8000` (Docker) or `http://host.containers.internal:8000` (Podman).

### 3. Tokens are not being restored during Unmask
* **Cause**: The `Token Mapping` parameter in the Unmask node is not referencing the mapping emitted by the Mask node.
* **Resolution**: In the Unmask node, ensure **Token Mapping** is set to expression:
  ```javascript
  ={{ $('PII Guardrails: Mask').item.json.mapping }}
  ```

---

## 🛡️ Security & Zero Data Retention Guarantees

Enterprise PII Guardrails is architected under strict Zero-Trust principles:
* **Zero Telemetry**: The server and connector emit zero telemetry, analytics, or external phone-home requests.
* **In-Memory Streaming**: All redaction and token mappings are computed in volatile memory. No customer payloads or prompt texts are logged or written to persistent disk during `/mask` and `/unmask` operations.
* **Deterministic Token Isolation**: Redacted tokens are generated using isolated session contexts, guaranteeing mathematical non-reversibility by third parties without the in-memory mapping dictionary.

---

## 📜 Intellectual Property & Licensing

Copyright (c) 2026 [piiguardrails.com](https://piiguardrails.com). All Rights Reserved.

This software connector is proprietary and confidential. It is licensed strictly for use with authorized Enterprise PII Guardrails server instances under the terms of [LICENSE.md](LICENSE.md).

* **Official Repository**: [https://github.com/piiguardrails/piiguardrails](https://github.com/piiguardrails/piiguardrails)
* **Website & Documentation**: [https://piiguardrails.com](https://piiguardrails.com)
* **Enterprise Licensing Inquiries**: [piiguardrails@gmail.com](mailto:piiguardrails@gmail.com)
