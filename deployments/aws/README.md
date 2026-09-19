# 1-Click AWS EC2 Deployment Guide

Deploy **Enterprise PII Guardrails** into your AWS account in under 3 minutes with zero manual server configuration.

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https%3A%2F%2Fpiiguardrails-public.s3.us-east-1.amazonaws.com%2Fpiiguardrails-ec2-1click.yaml&stackName=EnterprisePIIGuardrails)

---

## Overview

This CloudFormation template automatically provisions:
1. **EC2 Compute Instance**: Amazon Linux 2023 (`t3.medium` default, 2 vCPU, 4GB RAM) optimized for low-latency PII masking, NER recognition, and reversible tokenization.
2. **Encrypted Persistent Storage**: 20 GB `gp3` encrypted EBS volume mounting `/opt/piiguardrails/data` to safeguard encrypted SQLCipher audit databases and custom detection profiles across reboots.
3. **Hardened Container Runtime**: Runs the official production container (`piiguardrails/enterprise-pii-guardrail:latest`) under `systemd` supervisor management with auto-restart on crash or reboot.
4. **Preconfigured Evaluation License**: Includes an immediate free evaluation license (10,000 requests quota) so your team can test APIs, LangChain, and n8n workflows with zero delays.
5. **Security Group**: Ingress strictly restricted to Port 8000 (FastAPI engine & Studio Web UI) from your designated CIDR range.

---

## 1-Click Launch Instructions

### Step 1: Launch CloudFormation Stack
1. Click the **[Launch Stack](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https%3A%2F%2Fpiiguardrails-public.s3.us-east-1.amazonaws.com%2Fpiiguardrails-ec2-1click.yaml&stackName=EnterprisePIIGuardrails)** button above (or open CloudFormation in your AWS Console and upload `piiguardrails-ec2-1click.yaml`).
2. Select your preferred AWS Region (e.g. `us-east-1`, `eu-central-1`, `ap-south-1`).
3. Fill in the stack parameters:
   - **AdminPassword**: Choose a secure administrative password to log into the Studio Web UI.
   - **AllowedInboundCIDR**: Enter your office/VPN CIDR (e.g. `203.0.113.50/32`) or leave `0.0.0.0/0` for initial testing.
   - **InstanceType**: Keep `t3.medium` or select a larger instance.
   - **KeyPairName**: (Optional) Select an SSH key pair if you wish to connect via SSH.
4. Click **Next** ➡️ **Create Stack**.

### Step 2: Access Studio Web UI
1. Wait ~2–3 minutes for the CloudFormation stack status to display `CREATE_COMPLETE`.
2. Click on the **Outputs** tab in CloudFormation.
3. Click the `WebUIURL` link: `http://<YOUR-EC2-IP>:8000`.
4. Log in with:
   - **Username**: `admin`
   - **Password**: *(The password you specified in AdminPassword)*

---

## Upgrading from Trial to Node-Locked Production

When your evaluation period is complete, you can upgrade this existing EC2 instance to a permanent Node-Locked Production license **without losing any custom regexes, rules, or database history**:

1. Log into your Studio Web UI dashboard at `http://<YOUR-EC2-IP>:8000`.
2. Navigate to the **Licensing** tab in the admin dashboard.
3. You will see your server's unique **Server Hardware ID** (e.g., `A1B2-C3D4-E5F6-7890`).
4. Email this Hardware ID to **[piiguardrails@gmail.com](mailto:piiguardrails@gmail.com?subject=Commercial%20License%20Upgrade%20Request)** to request your production key.
5. Once received, paste your commercial license key into the **Activate License** field in the Web UI and click **Save**.
6. The instance immediately upgrades to permanent Production status in-place.

---

## Backup & Maintenance

All persistent state (SQLCipher AES-256 database, custom regex dictionaries, token vault, and audit logs) is stored on the host at:
```bash
/opt/piiguardrails/data/
```

- **EBS Snapshots**: You can create standard AWS EBS snapshots of the instance root volume at any time for zero-downtime backups.
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
