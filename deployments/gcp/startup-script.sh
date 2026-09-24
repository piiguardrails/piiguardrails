#!/bin/bash
# ==============================================================================
# Enterprise PII Guardrails - Google Cloud Compute Engine VM Startup Script
# ==============================================================================
# Automates Docker runtime configuration, persistent encrypted storage, and
# systemd service supervisor on Ubuntu 24.04 LTS.
# 
# Website: https://piiguardrails.com
# Documentation: https://piiguardrails.com/docs/gcp-gce.html
# ==============================================================================

set -e
exec > >(tee -a /var/log/piiguardrail-startup.log | logger -t piiguardrails -s 2>/dev/console) 2>&1

echo "=========================================================="
echo "Starting Enterprise PII Guardrails GCE Setup ($(date -u))"
echo "=========================================================="

# 1. Helper function to read Compute Engine Instance Metadata
get_metadata() {
    local key="$1"
    local default_val="$2"
    local val
    val=$(curl -s -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${key}" 2>/dev/null || true)
    if [ -n "$val" ]; then
        echo "$val"
    else
        echo "$default_val"
    fi
}

GUI_PASSWORD=$(get_metadata "gui_password" "")
if [ -z "$GUI_PASSWORD" ]; then
    GUI_PASSWORD=$(openssl rand -hex 12)
    echo "Generated secure random GUI password."
fi
COMPANY_NAME=$(get_metadata "company_name" "GCP Demo")
BRAND_LOGO=$(get_metadata "brand_logo" "/ui/logo.png")
DEFAULT_TRIAL_KEY="ED4-AQAGWNU7FAAAAJYQ-AAAAAAAAAAAAAKFI-VXRAU4YPAHXPW6JD-CRJIDR5NFJ4ITZA2-ICFCAEEV7OYVNWO7-JDSSZ5RMIUNDHULQ-DMZPYP4ICOFTJF53-AMKICAI6R57R4XM4-QYR4UGEQ4ZTP3DAM"
LICENSE_KEY=$(get_metadata "license_key" "$DEFAULT_TRIAL_KEY")
APP_PORT=$(get_metadata "app_port" "8000")

# 2. Update apt repository cache & install system dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    openssl

# 3. Install Docker Engine if not present
if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker CE..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -y
    apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io
fi

systemctl enable --now docker

# 4. Configure persistent host directory for encrypted database and audit records
mkdir -p /opt/piiguardrails/data
chmod 777 /opt/piiguardrails/data

# 5. Persist or generate 256-bit SQLCipher encryption passphrase
PASSPHRASE_FILE="/opt/piiguardrails/passphrase.key"
if [ ! -f "$PASSPHRASE_FILE" ]; then
    openssl rand -hex 16 > "$PASSPHRASE_FILE"
    chmod 600 "$PASSPHRASE_FILE"
fi
SQLCIPHER_PASSPHRASE=$(cat "$PASSPHRASE_FILE")

# 6. Generate hardened environment file for container execution
cat <<EOF > /etc/piiguardrails.env
ACCEPT_LICENSE=true
GUI_PASSWORD=${GUI_PASSWORD}
SQLCIPHER_PASSPHRASE=${SQLCIPHER_PASSPHRASE}
PRECONFIGURED_LICENSE_KEY=${LICENSE_KEY}
COMPANY_NAME=${COMPANY_NAME}
BRAND_LOGO=${BRAND_LOGO}
PORT=${APP_PORT}
APP_PORT=${APP_PORT}
APP_HOST=0.0.0.0
DATA_DIR=/app/data
EOF
chmod 600 /etc/piiguardrails.env

# 7. Create Systemd Service for container supervisor & auto-recovery
cat <<'EOF' > /etc/systemd/system/piiguardrail.service
[Unit]
Description=Enterprise PII Guardrails Service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
RestartSec=10
ExecStartPre=-/usr/bin/docker stop pii-guardrail-app
ExecStartPre=-/usr/bin/docker rm pii-guardrail-app
ExecStartPre=/usr/bin/docker pull piiguardrails/enterprise-pii-guardrail:latest
ExecStart=/usr/bin/docker run --name pii-guardrail-app \
  -p 8000:8000 \
  -v /opt/piiguardrails/data:/app/data \
  --env-file /etc/piiguardrails.env \
  piiguardrails/enterprise-pii-guardrail:latest
ExecStop=/usr/bin/docker stop pii-guardrail-app

[Install]
WantedBy=multi-user.target
EOF

# 8. Reload systemd, enable and start service
systemctl daemon-reload
systemctl enable piiguardrail.service
systemctl restart piiguardrail.service

# 9. Query external IP from GCP metadata to print direct access URL
EXT_IP=$(curl -s -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip" 2>/dev/null || true)
if [ -z "$EXT_IP" ]; then
    EXT_IP=$(curl -s -f https://ifconfig.me 2>/dev/null || true)
fi

echo "=========================================================="
echo "Enterprise PII Guardrails initialized successfully!"
if [ -n "$EXT_IP" ]; then
    echo "Web Studio Live URL: http://${EXT_IP}:${APP_PORT}"
    echo "OpenAPI Specs:       http://${EXT_IP}:${APP_PORT}/docs"
else
    echo "Service is running on port ${APP_PORT}."
fi
echo "=========================================================="
