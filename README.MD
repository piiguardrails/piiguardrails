<div align="center">

# 🛡️ Enterprise PII Guardrails Studio

**High-Performance, Zero-Leak AI Privacy Gateway for Enterprise LLM Pipelines**

[![PyPI Version](https://img.shields.io/pypi/v/piiguardrails?color=blue&label=PyPI%20Package)](https://pypi.org/project/piiguardrails/)
[![Python Version](https://img.shields.io/badge/python-%3E%3D%203.8-3776AB?logo=python&logoColor=white)](https://pypi.org/project/piiguardrails/)
[![Security](https://img.shields.io/badge/Security-AES--256%20SQLCipher-blueviolet)](https://github.com/piiguardrails/piiguardrails)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20x64-0078D4?logo=linux&logoColor=white)](https://pypi.org/project/piiguardrails/)

<br/>

[**PyPI Package**](https://pypi.org/project/piiguardrails/) • [**Documentation**](https://github.com/piiguardrails/piiguardrails#readme) • [**Report Issue**](https://github.com/piiguardrails/piiguardrails/issues)

</div>

---

## ⚡ Overview

**Enterprise PII Guardrails Studio** is an ultra-fast, defense-in-depth privacy gateway designed to intercept, detect, mask, and pseudonymize Personally Identifiable Information (PII) before it ever touches public LLM APIs (OpenAI, Anthropic, Gemini) or third-party vector databases.

Equipped with an in-memory authorization cache, asynchronous audit pipeline, and multi-tier regex + NLP models, it sustains **sub-25ms live masking latency** while safeguarding compliance with **GDPR, HIPAA, PCI-DSS, and CCPA**.

---

## 🚀 Quickstart

### Method 1: Using `pip` (Standard Python)

```bash
# 1. Install from PyPI
pip install piiguardrails

# 2. Launch the studio
piiguardrails
```

---

### Method 2: Using `uv` (Instant Sandbox — Zero Setup)

Run directly in a self-contained, isolated environment without polluting global Python:

```bash
uv run --with piiguardrails piiguardrails
```

---

### 🖥️ First-Run Setup & UI Access

On first launch, `piiguardrails` automatically provisions the core engine and configures your encrypted local database.

1. A quick 30-second setup wizard prompts you in the terminal for your **Company Name** and **Admin Password**.
2. Once initialized, the studio launches on:
   👉 **`http://localhost:8000`**
3. Log in with your admin credentials to access the live dashboard, manage API keys, customize PII detection rules, and monitor telemetry.

---

### 🎁 Community Launch Promo: 6 Months Free Enterprise

To celebrate our v2.0 release, early adopters can unlock full **Enterprise Tier** features (unlimited API requests, unrestricted payload length, and custom regex policies) through **March 31, 2027**:

```text
ED3-AMBGXK7UVD777777-GRYXEUYUZ432JOHY-UWVDBHXRLAXU4U47-7MBK2DQGIUV4JQT6-UJNRXNTHI3JPBGIS-P66HGKVYNLMQXHHS-M3N4RF3XDN6LZILT-WQNCGJ4KEY6ONIIM
```

**To activate:**
1. Open the studio dashboard (`http://localhost:8000`).
2. Go to the **License** tab in the sidebar.
3. Paste the key above and click **Activate License**.

---

## 🧩 Python Integration Example

Once the studio is running, integrate it directly into your LangChain, LlamaIndex, or raw API pipeline:

```python
import requests

API_KEY = "your-api-key-here"  # Generated in the Studio UI
headers = {"X-API-Key": API_KEY, "Content-Type": "application/json"}

# 1. Mask sensitive input before sending to LLM
payload = {
    "text": "Hello Alice Smith, your verification code was sent to alice.smith@acme.corp. Call us at 415-555-2671."
}

mask_response = requests.post("http://localhost:8000/mask", json=payload, headers=headers).json()
print("Masked text for LLM:", mask_response["masked_text"])
# Output: "Hello <PERSON_1>, your verification code was sent to <EMAIL_1>. Call us at <PHONE_1>."

# 2. Query your LLM with safe, masked prompt...
# simulated_llm_reply = "We contacted <PERSON_1> at <EMAIL_1> regarding the ticket."

# 3. Unmask the LLM response back to real entities for your user
unmask_payload = {
    "text": "We contacted <PERSON_1> at <EMAIL_1>.",
    "mapping": mask_response["mapping"]
}
unmask_response = requests.post("http://localhost:8000/unmask", json=unmask_payload, headers=headers).json()
print("Restored response:", unmask_response["unmasked_text"])
# Output: "We contacted Alice Smith at alice.smith@acme.corp."
```

---

## 🛡️ Key Capabilities & Architecture

| Feature | Description |
| :--- | :--- |
| **Blazing Fast (<25ms)** | In-memory LRU authorization caching + asynchronous non-blocking SQLite/SQLCipher audit worker thread. |
| **30+ Entity Recognizers** | SSN, Credit Cards, IBAN, Passports, Names, Emails, Phone Numbers, IP/MAC addresses, API keys, JWTs, Medical IDs. |
| **AES-256 Storage** | Built-in SQLCipher encryption ensures all audit logs, API keys, and configurations are hardware-locked and encrypted at rest. |
| **Zero-Footprint Cleanup** | Automatic boot-time and shutdown sweeps safely purge temporary runtime artifacts to prevent disk bloat across repeated runs. |
| **Modern Management UI** | Material Design 3 / MUI dashboard for live telemetry, access keys, policy rules, and audit logs. |
| **Deterministic Reverse Tokenizer** | Flawless restoration (`/unmask`) of LLM responses back to original values for authorized consumers. |

---

## 📋 System Requirements

- **Operating System**: Windows 10, Windows 11, Windows Server (64-bit) or Linux (Ubuntu, Debian, RHEL, CentOS, Fedora, Rocky, Arch, WSL2 x86_64)
- **Python**: `>= 3.8` (or `uv`)
- **Memory**: Minimum 2 GB RAM
- **Port**: Default `8000` (configurable via `.env` or `--port`)

---

## 📄 License

This software is distributed under the [Enterprise Software License and Evaluation Agreement](LICENSE). All rights reserved.
