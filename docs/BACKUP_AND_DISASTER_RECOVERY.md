# Disaster Recovery, Backup & Server Migration Guide

This guide details operational procedures for backing up, restoring, and migrating **Enterprise PII Guardrails Studio** across hosts, virtual machines, or container environments.

---

## 🔐 Core Architecture: The Dual-Key Security Model

The system protects all operational state, API keys, custom regex patterns, and audit trails using **SQLCipher AES-256-CBC database encryption**.

To achieve a complete restore or recreate the application on another machine, understand the relationship between two essential components:

```text
┌─────────────────────────────────────────────────────────┐
│ Host Environment / Host Filesystem                      │
│                                                         │
│   1. Configuration Secrets (.env)                       │
│      ├── SQLCIPHER_PASSPHRASE  (Database Master Key)    │
│      ├── GUI_PASSWORD          (Admin Web Console Pass) │
│      └── BRAND_LOGO, APP_NAME  (Branding Settings)      │
│                                                         │
│   2. Encrypted Database File (data/api_keys.db)         │
│      ├── Hashed API Access Keys & Scopes                │
│      ├── Active Guardrail Profiles & Custom Regex Rules │
│      ├── Threat Intelligence (Blocked IPs & Domains)    │
│      └── Encrypted Audit Trail Logs                     │
└─────────────────────────────────────────────────────────┘
```

> [!IMPORTANT]
> The database (`data/api_keys.db`) is cryptographically sealed using `SQLCIPHER_PASSPHRASE`. If you possess the `.db` file but lose the `SQLCIPHER_PASSPHRASE`, the database is mathematically unrecoverable.

---

## 💾 Standard Backup Procedure

### Automated Backups
1. The built-in maintenance worker automatically creates point-in-time snapshots of the database according to your configured schedule (e.g., hourly or daily).
2. Automated backups are stored in:
   - **Linux / Docker**: `data/backups/` or `/app/data/backups/`
   - **Windows**: `%APPDATA%\piiguardrails\data\backups\` or `<install_dir>\data\backups\`

### Manual Cold Backup (Recommended for Migrations)
To take a pristine backup of your entire instance:

1. Stop the running service:
   ```bash
   # Standalone executable: CTRL+C
   # Or Docker:
   docker stop pii-guardrail-studio
   ```

2. Copy the two critical assets to a secure offline vault:
   - `.env`
   - `data/api_keys.db` (or entire `data/` directory)

---

## 🔄 Recreating the App on a New Server

To replicate or migrate your exact configuration to a new host machine:

### Step 1: Install the Runtime Engine
On the destination machine, install the package or copy the binary:

```bash
pip install piiguardrails
# OR download standalone binary EnterprisePIIGuardrail_linux_x86_64
```

### Step 2: Restore Secrets and Database
1. Copy your backed-up `.env` file into the application working directory.
2. Ensure `SQLCIPHER_PASSPHRASE` matches the source server's passphrase exactly.
3. Copy your backed-up `api_keys.db` into the `data/` folder.

### Step 3: Launch the Service
```bash
piiguardrails
```
The application will decrypt the database, load all existing API keys, restore custom regex patterns, and resume serving requests immediately.

---

## 🛡️ License Behavior During Server Migration

When migrating `data/api_keys.db` to a new host, the behavior depends on the license version:

| License Type | What Happens on the New Machine? | Action Required |
| :--- | :--- | :--- |
| **Version 3 (Floating / Promo Key)** | **Activates Immediately**: Version 3 keys are universal and not bound to hardware identifiers. | None. All quotas and features carry over automatically. |
| **Version 4 (Node-Locked Key)** | **Prompts for Re-Licensing**: Version 4 keys are cryptographically locked to the source machine's Server Hardware ID. The new machine has a different Hardware ID, so the engine drops to Trial tier until updated. | 1. Open the new studio dashboard at `http://<new-ip>:8000`.<br/>2. Retrieve the new machine's **Server Hardware ID** from **Settings > License & Quota**.<br/>3. Contact your account manager to issue an updated key bound to the new Server Hardware ID. |

---

## 🧹 Automated Log Retention & Purging

To ensure the encrypted audit database does not consume disk space indefinitely:

1. Open the studio dashboard and navigate to **Settings > Security & Performance**.
2. Configure **Audit Log Retention Period** (e.g. `30 Days`).
3. The background maintenance thread automatically purges expired audit entries while retaining summary telemetry counters.
