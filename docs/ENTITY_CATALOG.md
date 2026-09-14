# 🗂️ Built-in Entity Recognizers & Detection Catalog

Enterprise PII Guardrails Studio bundles **30+ deterministic, context-aware recognizers** engineered to detect, classify, and redact sensitive data with near-zero false positive rates.

---

## 📋 Complete Recognizer Matrix

| Category | Entity Key | Engine Identifier | Detection Technique | Algorithmic Validation / Checksum | Default Strategy |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Core PII** | `PERSON` | `PERSON` | Context-Aware NER + Name Dictionaries | Statistical context window scoring | Reversible Token (`<PERSON_1>`) |
| **Core PII** | `EMAIL` | `EMAIL_ADDRESS` | RFC 5322 Compliant Regex | Top-Level Domain (TLD) boundary check | Reversible Token (`<EMAIL_1>`) |
| **Core PII** | `PHONE` | `PHONE_NUMBER` | E.164 & International Format Regex | Country code & digit count verification | Reversible Token (`<PHONE_1>`) |
| **Core PII** | `STREET_ADDRESS` | `LOCATION` | Contextual Street Suffix Scanning | Landmark / address vocabulary matching | Reversible Token (`<LOCATION_1>`) |
| **Core PII** | `DATE_OF_BIRTH` | `DATE_OF_BIRTH` | Contextual Date Pattern Matching | Calendar validity & context keyword | Mask (`YYYY-MM-DD`) |
| **Core PII** | `PASSPORT` | `PASSPORT` | Standard ICAO Machine-Readable Regex | Alphanumeric check | Reversible Token (`<PASSPORT_1>`) |
| **Core PII** | `DRIVERS_LICENSE` | `DRIVERS_LICENSE` | State / National DL Format Patterns | Contextual prefix matching | Reversible Token (`<DL_1>`) |
| **Financial** | `CREDIT_CARD` | `CREDIT_CARD` | 13-19 Digit Card Number Regex | **MOD 10 Luhn Checksum** validation | Reversible Token / `partial_last4` |
| **Financial** | `CREDIT_CARD_CVV` | `CREDIT_CARD_CVV` | 3-4 Digit Security Code Regex | Proximity to card number or CVV keywords | Full Redaction (`***`) |
| **Financial** | `CREDIT_CARD_EXPIRY` | `CREDIT_CARD_EXPIRY`| MM/YY & MM/YYYY Patterns | Date validity (01-12 month range) | Full Redaction (`**/**`) |
| **Financial** | `BANK_ACCOUNT` | `BANK_ACCOUNT` | 8-18 Digit Domestic Account Regex | Proximity to routing / account labels | Reversible Token (`<BANK_ACCOUNT_1>`) |
| **Financial** | `ROUTING_NUMBER` | `ROUTING_NUMBER` | 9-Digit ABA Routing Transit Regex | **ABA Checksum algorithm** (3·7·1 weights)| Full Redaction (`*********`) |
| **Financial** | `FINANCIAL_IBAN` | `FINANCIAL_IBAN` | ISO 13616 International Account | **MOD 97-10 Checksum (ISO 7064)** | Reversible Token (`<IBAN_1>`) |
| **Financial** | `SWIFT_CODE` | `SWIFT_CODE` | 8 or 11 Character BIC Format | Country code & institution lookup | Reversible Token (`<SWIFT_1>`) |
| **Healthcare** | `MEDICAL_RECORD` | `MEDICAL_RECORD` | Alphanumeric MRN Format Regex | Contextual EHR keywords (patient, admitted) | Reversible Token (`<MRN_1>`) |
| **Healthcare** | `PATIENT_ID` | `PATIENT_ID` | Enterprise EHR Patient Identifier | Hospital prefix & context window | Reversible Token (`<PATIENT_1>`) |
| **Healthcare** | `INSURANCE_ID` | `INSURANCE_ID` | Member / Policy Group ID Regex | Payer / policy context validation | Reversible Token (`<INSURANCE_1>`) |
| **IT & DevOps** | `PASSWORD` | `PASSWORD` | Key-Value & Assignment Pattern Regex | Entropy scoring & context exclusion | Full Mask (`****************`) |
| **IT & DevOps** | `PIN` | `PIN` | 4-6 Digit Security PIN Regex | Negative lookaheads for dates/years | Full Mask (`****`) |
| **IT & DevOps** | `AWS_ACCESS_KEY` | `AWS_ACCESS_KEY` | Exact Regex `AKIA[0-9A-Z]{16}` | 20-character AWS standard check | Full Mask (`********************`) |
| **IT & DevOps** | `JWT_TOKEN` | `JWT_TOKEN` | Base64 Three-Part Token `eyJ...` | Header decoding & signature boundary | Full Redaction (`[JWT_TOKEN]`) |
| **IT & DevOps** | `API_KEY_OPENAI` | `API_KEY_OPENAI` | `sk-[a-zA-Z0-9]{48,}` Prefix | Secret length & character pool check | Full Mask (`****************`) |
| **IT & DevOps** | `API_KEY_GITHUB` | `API_KEY_GITHUB` | `ghp_[a-zA-Z0-9]{36}` Prefix | GitHub personal access token spec | Full Mask (`****************`) |
| **IT & DevOps** | `GENERIC_SECRET` | `GENERIC_SECRET` | High-Entropy Hex/Base64 Strings | Shannon entropy calculation (>4.5) | Full Mask (`****************`) |
| **IT & DevOps** | `CRYPTO_KEY` | `CRYPTO_KEY` | RSA / EC Private Key Headers | `-----BEGIN PRIVATE KEY-----` | Full Redaction (`[PRIVATE_KEY]`) |
| **IT & DevOps** | `IP_ADDRESS` | `IP_ADDRESS` | IPv4 & IPv6 Address Regex | Octet range validation (0-255) | Reversible Token (`<IP_1>`) |
| **IT & DevOps** | `MAC_ADDRESS` | `MAC_ADDRESS` | Colon/Hyphen Hex MAC Address | 6-octet hexadecimal byte check | Reversible Token (`<MAC_1>`) |
| **India DPDP** | `AADHAAR` | `AADHAAR` | 12-Digit UIDAI Format (`\b[2-9]\d{3}[ -]?\d{4}[ -]?\d{4}\b`) | **Verhoeff Checksum Algorithm** (Dihedral D5) | Statutory Mask (`XXXX-XXXX-1234`) |
| **India DPDP** | `PAN_CARD` | `PAN_CARD` | Income Tax 10-Char Regex `[A-Z]{5}[0-9]{4}[A-Z]` | 4th char status code (P, C, H, F, A, T) | Statutory Mask (`AXXXXX234F`) |
| **India DPDP** | `ABHA_NUMBER` | `ABHA_NUMBER` | 14-Digit ABDM Health ID (`\d{2}-\d{4}-\d{4}-\d{4}`) | Standard prefix & length verification | Statutory Mask (`XX-XXXX-XXXX-1234`) |
| **India DPDP** | `UPI_ID` | `UPI_ID` | Virtual Payment Address (`user@bank`) | PSP handle allowlist (`okaxis`, `okhdfc`, etc.) | Full Mask (`****************`) |
| **India DPDP** | `IFSC_CODE` | `IFSC_CODE` | RBI 11-Char Code `[A-Z]{4}0[A-Z0-9]{6}` | 5th character must be zero (`0`) | Full Mask (`***********`) |

---

## 🛡️ False-Positive Mitigation Architecture

Enterprise PII Guardrail employs a multi-tiered false-positive elimination strategy:
1. **Mathematical Checksums**: Entities with standardized digits (Credit Cards, Aadhaar, IBAN, US Routing Numbers) MUST pass strict mathematical verification before being flagged. Random strings of digits are silently ignored.
2. **Context Window Verification**: Ambiguous identifiers (such as PINs or Dates) require proximity to context keywords (e.g., `pin:`, `code:`, `dob:`, `born`) within a 30-character bidirectional window.
3. **Deterministic Allowlists**: Benign JSON keys (`"ticket_id"`, `"user_id"`, `"status"`), corporate domain names, and known benign codes can be exempted using negative lookaheads (`(?!(?:...))`).
