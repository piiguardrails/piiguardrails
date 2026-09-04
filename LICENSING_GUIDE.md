# Enterprise PII Guardrails Studio - Customer License & Activation Guide

This guide explains how commercial licensing works for **Enterprise PII Guardrails Studio** and how to activate your software in secure, on-premise, or air-gapped environments.

---

## 🛡️ Zero-Phone-Home Architecture (100% Offline)

Enterprise PII Guardrails Studio uses **offline cryptographic asymmetric signatures** to validate license keys. 

- **Complete Air-Gap Compliance**: Your deployment **never** connects to any external cloud, telemetry service, or licensing server to validate or renew its license.
- **Strict Data Sovereignty**: All processing, validation, and storage remain strictly contained within your own infrastructure.

---

## 📸 How to Retrieve Your Server Hardware ID

For commercial Enterprise nodes, licenses are node-locked to your designated server hardware to guarantee operational integrity.

To find your unique **Server Hardware ID**:

1. Log into your PII Guardrail Studio dashboard (`http://localhost:8000`).
2. Navigate to **Settings** in the sidebar navigation.
3. Click the **License & Quota** tab.
4. Your unique **Server Hardware ID** is displayed under the **Current License Status** card:

![Server Hardware ID in Studio UI](docs/assets/license_management.png)

5. Copy this ID and provide it to your enterprise account representative to receive your signed commercial product key.

---

## 🔑 Activating a Product Key

Once your product key has been issued by your account manager:

1. In the studio dashboard, open **Settings > License & Quota**.
2. Scroll to the **Activate New License** card.
3. Paste your issued product key into the **Product Key** input field.
4. Click **Activate License**.
5. The dashboard will immediately validate the key and update your active tier, daily quotas, and expiration date.

---

## 🎁 Free Community Launch Evaluation (6 Months Enterprise)

Early adopters and evaluators can activate a full **Enterprise Tier** evaluation key valid through **March 31, 2027**:

```text
ED3-AMBGXK7UVD777777-GRYXEUYUZ432JOHY-UWVDBHXRLAXU4U47-7MBK2DQGIUV4JQT6-UJNRXNTHI3JPBGIS-P66HGKVYNLMQXHHS-M3N4RF3XDN6LZILT-WQNCGJ4KEY6ONIIM
```

Simply paste the key above into the **License & Quota** activation box to unlock unlimited requests and all 30+ entity recognizers.

---

## 📊 License Tiers & Operational Quotas

| Tier | API Request Quota | Max Payload Size | Custom Regex Patterns | Included Features |
| :--- | :---: | :---: | :---: | :--- |
| **Trial** | 1,000 requests/day | 5,000 characters | Up to 2 Patterns | Full UI, 30+ Entity Recognizers, Threat Intelligence, Audit Logging |
| **Standard** | 20,000 requests/day | 50,000 characters | Up to 5 Patterns | Full UI, 30+ Entity Recognizers, Threat Intelligence, Audit Logging |
| **Enterprise** | **Unlimited** | **Unrestricted** | **Unlimited** | Node-Locked Hardware Binding, Dedicated Support, Unrestricted Throughput |
