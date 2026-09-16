# Official n8n Template Submission Package

This artifact contains the metadata, title, SEO description, and verified workflow JSON ready for submission to the official [n8n Creator Portal](https://creator.n8n.io) in accordance with the official [n8n Template Submission Guidelines](https://n8n.notion.site/Template-submission-guidelines-9959894476734da3b402c90b124b1f77).

---

## 1. Submission Metadata

| Field | Value | Notes |
| :--- | :--- | :--- |
| **Template Title** | `Redact sensitive PII in AI prompts and restore responses with Enterprise PII Guardrails` | Strictly adheres to: `Action verb + thing being manipulated + with/to/in where` (sentence-case, no emojis) |
| **Primary Category** | `AI` | High-intent search ranking |
| **Secondary Categories / Tags** | `Security`, `Privacy`, `OpenAI`, `Compliance`, `Community Nodes` | Discoverability tags |
| **Package Dependency** | `n8n-nodes-piiguardrails` (npm v0.1.6) | Official Community Node |
| **Required n8n Version** | `v1.0.0+` | Self-hosted (Docker / npm / Desktop) |

---

## 2. Description (Ready to Copy/Paste)

> Copy and paste the Markdown block below directly into the **Description** field of the n8n Creator Portal. It satisfies all 5 recommended sections, includes the community node disclaimer, embeds the workflow architecture diagram, and is optimized to ~220 words.

```markdown
![Enterprise PII Guardrails Workflow](https://raw.githubusercontent.com/piiguardrails/piiguardrails/main/website/docs/n8n/architecture-flow.svg)

> **Note**: This workflow uses the community node `n8n-nodes-piiguardrails`. Custom community nodes are supported on self-hosted n8n instances (Docker, npm, or desktop).

### Who's it for
For developers, security teams, and AI engineers building enterprise LLM workflows who need to comply with GDPR, HIPAA, or PCI-DSS by preventing sensitive personal data from leaking to cloud AI providers.

### How it works
1. **Ingestion**: Receives a customer prompt containing sensitive identifiers (names, emails, phone numbers, credit card numbers, medical record numbers).
2. **Masking**: The Enterprise PII Guardrails node scrubs sensitive entities locally (<25ms) and replaces them with cryptographic surrogate tokens (e.g., `[HUMAN_NAME_1]`).
3. **LLM Inference**: The sanitized prompt is forwarded to an AI model (OpenAI, Claude, Gemini, or local models). The model reasons over placeholders with zero data leakage.
4. **Unmasking**: The response is de-anonymized inside your secure infrastructure by restoring the original entities using the session token map.

### How to set up
1. Install the community node in n8n via **Settings > Community Nodes > Install** and enter `n8n-nodes-piiguardrails`.
2. Start the local privacy proxy:
   ```bash
   pip install piiguardrails
   piiguardrails start
   ```
3. In n8n, create an **Enterprise PII Guardrails API** credential pointing to `http://localhost:8000`.
4. Click **Test step** on the manual trigger to execute the end-to-end pipeline.

### Requirements
- Self-hosted n8n instance (v1.0.0+)
- `n8n-nodes-piiguardrails` community package
- Local or self-hosted Enterprise PII Guardrails gateway (`localhost:8000` or private server)

### How to customize the workflow
- Replace the simulated LLM node with native **OpenAI Chat Model**, **Anthropic**, or **Ollama** nodes.
- Connect a **Webhook** or **Slack Trigger** to protect inbound user communications automatically.
```

---

## 3. Workflow Canvas Structure & Sticky Notes

In compliance with the **Sticky note guidelines for templates**, this workflow includes:
1. **Yellow Sticky Note (`#sticky-main-overview`)**:
   - Dimensions: `460 x 380`, Color: `4` (Yellow)
   - Contains the template overview, value proposition, and quickstart instructions.
2. **Four Phase Sticky Notes (`#sticky-phase-1` to `#sticky-phase-4`)**:
   - Color: `7` (Neutral/Gray)
   - Visually group each stage: **1. Ingestion**, **2. PII Scrubbing**, **3. LLM Inference**, and **4. Restore PII**.
3. **Descriptive Node Names**:
   - `Manual Test Trigger`
   - `Set Customer Prompt with PII`
   - `Mask PII with Enterprise Guardrails`
   - `Process Prompt with LLM (Simulated)`
   - `Restore Original PII from Tokens`
4. **Zero Hardcoded Secrets**:
   - Generic credential link (`Enterprise PII Guardrails API`).
   - Zero personal identity leaks, zero personal emails or tokens.

---

## 4. Step-by-Step Submission Instructions

1. **Sign In to n8n Creator Portal**:
   - Go to [https://creator.n8n.io](https://creator.n8n.io) (or register via [n8n Creator Hub](https://n8n.io)).
2. **Click "Share new template"**:
   - In your Creator dashboard, click the **Share new template** button.
3. **Paste the Workflow JSON**:
   - Upload or paste `workflows/Local_PII_Safe_LLM_Pipeline.json`.
4. **Paste Title**:
   - Enter: `Redact sensitive PII in AI prompts and restore responses with Enterprise PII Guardrails`
5. **Paste Description**:
   - Copy the Markdown block from Section 2 above and paste it into the description editor.
6. **Select Categories & Tags**:
   - Primary: **AI**
   - Tags: **Security**, **Privacy**, **OpenAI**, **Community Nodes**
7. **Submit for Review**:
   - Click **Submit**. The n8n team manually reviews new templates within ~1 week.
