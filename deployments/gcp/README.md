# Google Cloud Platform (GCP) Compute Engine Deployment Guide

Deploy **Enterprise PII Guardrails** into your Google Cloud Platform project in under 3 minutes with automated Docker configuration, persistent encrypted storage, and evaluation licensing (10,000 requests included).

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fpiiguardrails%2Fpiiguardrails&cloudshell_workspace=deployments/gcp&cloudshell_tutorial=README.md)

---

## Architecture Overview

This deployment package provisions:
1. **Compute Engine VM**: Ubuntu 24.04 LTS on `e2-standard-2` (2 vCPU, 8GB RAM), pre-tuned for low-latency PII tokenization and high-throughput LLM gateway masking.
2. **Persistent Storage**: 30 GB balanced persistent disk mounted to host `/opt/piiguardrails/data` with 777/700 permissions to preserve encrypted SQLCipher databases, token vaults, and audit trails across VM stops and reboots.
3. **Hardened Container Runtime**: Executes the official container `piiguardrails/enterprise-pii-guardrail:latest` managed by a `systemd` daemon (`piiguardrail.service`) with auto-restart on failure.
4. **VPC Firewall Rule**: Automatically creates `allow-piiguardrails-8000` to expose Port 8000 for the Web Studio and REST API.
5. **Evaluation License**: Includes an evaluation license (10,000 requests quota) with instant in-place upgrade via Server Hardware ID (HWID).

---

## Deployment Options

### Method 1: 1-Click Interactive Cloud Shell (Recommended)

1. Click the **[Open in Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fpiiguardrails%2Fpiiguardrails&cloudshell_workspace=deployments/gcp&cloudshell_tutorial=README.md)** button above.
2. In the Google Cloud Shell terminal, run:
   ```sh
   bash deploy.sh
   ```
3. Follow the interactive prompts for:
   - Admin Studio Password (min 8 characters)
   - Company / Organization Name (default: `GCP Demo`)
   - Region & Zone (default: `us-central1-a`)
4. The script provisions the VM, checks firewall rules, and outputs your direct Web Studio URL.

---

### Method 2: Direct `gcloud` CLI (1-Liner)

Run this single command from your local terminal with Google Cloud SDK or in Cloud Shell:

```bash
gcloud compute instances create piiguardrail-gce \
  --zone=us-central1-a \
  --machine-type=e2-standard-2 \
  --image-family=ubuntu-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=30GB \
  --boot-disk-type=pd-balanced \
  --tags=http-server,piiguardrails \
  --metadata=company_name="GCP Demo",gui_password="<YOUR_SECURE_PASSWORD>" \
  --metadata-from-file=startup-script=<(curl -sSL https://raw.githubusercontent.com/piiguardrails/piiguardrails/main/deployments/gcp/startup-script.sh)
```

To open port 8000 on your default VPC network:
```bash
gcloud compute firewall-rules create allow-piiguardrails-8000 \
  --allow=tcp:8000 \
  --target-tags=piiguardrails \
  --description="Allow inbound traffic to Enterprise PII Guardrails Studio"
```

---

### Method 3: Enterprise Terraform Module

If your organization manages cloud infrastructure via Terraform:

```bash
cd deployments/gcp
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

View outputs:
```bash
terraform output studio_web_ui_url
```

---

## Accessing Studio Web UI

1. After creation, wait ~2 to 3 minutes for Docker and the container to initialize.
2. Open your browser and navigate to:
   ```text
   http://<YOUR_GCP_EXTERNAL_IP>:8000
   ```
3. Log in with:
   - **Username**: `admin`
   - **Password**: *(The password configured during setup)*

Interactive OpenAPI documentation is available at:
```text
http://<YOUR_GCP_EXTERNAL_IP>:8000/docs
```

---

## Upgrading to Node-Locked Production

All configurations, custom regex patterns, and audit logs persist across reboots in `/opt/piiguardrails/data`. You do not need to recreate the VM when upgrading from evaluation to production:

1. In the Studio Web UI, open the **Licensing** tab.
2. Copy your 16-character **Server Hardware ID** (e.g. `A1B2-C3D4-E5F6-7890`).
3. Email this Hardware ID to **[piiguardrails@gmail.com](mailto:piiguardrails@gmail.com?subject=GCP%20Commercial%20License%20Upgrade%20Request)** to request your production license key.
4. Paste the license key into the **Activate License** input and click **Activate**.
5. Your instance upgrades immediately in-place with zero downtime.

---

## Data Sovereignty & Security

- **100% In-VPC Execution**: All sensitive PII inspection, token masking, and unmasking occur entirely within your Google Cloud Compute Engine VM. Zero payload data or customer tokens ever leave your VPC perimeter.
- **SQLCipher AES-256**: All configuration state and audit trails are encrypted at rest using host-level passphrases.
