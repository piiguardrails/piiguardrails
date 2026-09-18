# 1-Click Microsoft Azure VM Deployment Guide

Deploy **Enterprise PII Guardrails** into your Microsoft Azure subscription in under 3 minutes with zero manual server configuration.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpiiguardrails%2Fpiiguardrails%2Fmain%2Fdeployments%2Fazure%2Fazuredeploy.json)

---

## Overview

This Azure Resource Manager (ARM) template automatically provisions:
1. **Azure Compute VM**: Canonical Ubuntu 24.04 LTS (`Standard_D2s_v7` default, 2 vCPU, 8GB RAM) optimized for ultra-low latency PII masking, NER tokenization, and custom regex profiling. Supported across all Azure availability zones with guaranteed compute capacity.
2. **Encrypted Persistent Storage**: 30 GB Premium SSD managed OS disk mounting `/opt/piiguardrails/data` to preserve your encrypted SQLCipher audit databases and token vaults across VM restarts or deallocations.
3. **Hardened Container Runtime**: Runs the official production container (`piiguardrails/piiguardrails:latest`) under `systemd` supervisor management with auto-restart on crash or reboot.
4. **Preconfigured Evaluation License**: Includes an immediate free evaluation license (10,000 requests quota) so your team can test APIs, LangChain, n8n workflows, and Studio Web UI with zero delays.
5. **Network Security Group (NSG)**: Ingress strictly restricted to Port 8000 (FastAPI engine & Studio Web UI) and Port 22 (SSH) from your designated CIDR range.

---

## 1-Click Launch Instructions

### Step 1: Deploy Template in Azure Portal
1. Click the **[Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpiiguardrails%2Fpiiguardrails%2Fmain%2Fdeployments%2Fazure%2Fazuredeploy.json)** button above.
2. Select your Azure **Subscription** and choose or create a **Resource Group** (e.g. `rg-piiguardrails`).
3. Select your preferred Azure **Region** (recommended: `East US 2`).
4. Fill in the template parameters:
   - **Admin Studio Password**: Choose a secure administrative password (min 8 chars) to log into the Studio Web UI (username: `admin`).
   - **Admin Username**: Default is `azureuser`.
   - **Authentication Type**: Select `password` or `sshPublicKey`.
   - **Admin Password Or Key**: Enter your SSH public key or VM password.
   - **Allowed Inbound CIDR**: Enter your office/VPN CIDR (e.g. `203.0.113.50/32`) or leave `*` for initial sandbox testing.
   - **Compute Specification**: Automated baseline of `Standard_D2s_v7` (2 vCPU, 8GB RAM) with 30GB Premium SSD. Broadly available across all zones and easily scaled up in the Azure Portal after deployment if required.
5. Click **Review + create** ➡️ **Create**.

### Step 2: Access Studio Web UI
1. Wait ~2–3 minutes for the Azure deployment status to show **Deployment succeeded**.
2. Click **Go to resource group** or view the **Outputs** tab of the deployment.
3. Click the `webUIURL` link: `http://<YOUR-AZURE-PUBLIC-IP>:8000`.
4. Log in with:
   - **Username**: `admin`
   - **Password**: *(The password you specified in Admin Studio Password)*

---

## Upgrading from Trial to Node-Locked Production

When your evaluation period is complete, you can upgrade this existing Azure VM to a permanent Node-Locked Production license **without losing any custom regexes, rules, or database history**:

1. Log into your Studio Web UI dashboard at `http://<YOUR-AZURE-PUBLIC-IP>:8000`.
2. Navigate to the **Licensing** tab in the admin dashboard.
3. You will see your server's unique **Server Hardware ID** (e.g., `A1B2-C3D4-E5F6-7890`).
4. Email this Hardware ID to **[piiguardrails@gmail.com](mailto:piiguardrails@gmail.com?subject=Azure%20Commercial%20License%20Upgrade%20Request)** to request your production key.
5. Once received, paste your commercial license key into the **Activate License** field in the Web UI and click **Save**.
6. The instance immediately upgrades to permanent Production status in-place.

---

## Backup & Maintenance

All persistent state (SQLCipher AES-256 database, custom regex dictionaries, token vault, and audit logs) is stored on the host at:
```bash
/opt/piiguardrails/data/
```

- **Azure Disk Snapshots**: You can create standard Azure Managed Disk snapshots of the OS disk at any time for zero-downtime backups.
- **Service Management**:
  ```bash
  # Check service status
  sudo systemctl status piiguardrail.service

  # View live container logs
  sudo journalctl -u piiguardrail.service -f
  ```

---

## Support & Enterprise Licensing

For commercial pricing, custom compliance packages (HIPAA, GDPR, PCI-DSS, DPDP), or enterprise SLAs:
- **Email**: [piiguardrails@gmail.com](mailto:piiguardrails@gmail.com)
- **Website**: [https://piiguardrails.com](https://piiguardrails.com)
- **GitHub**: [https://github.com/piiguardrails/piiguardrails](https://github.com/piiguardrails/piiguardrails)
