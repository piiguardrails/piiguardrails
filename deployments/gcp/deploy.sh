#!/bin/bash
# ==============================================================================
# Enterprise PII Guardrails - Google Cloud 1-Click Interactive Deployment
# ==============================================================================
# Launches a hardened Compute Engine VM with Docker and Enterprise PII Guardrails.
# Compatible with Google Cloud Shell and standard bash terminals.
#
# Usage:
#   ./deploy.sh
# ==============================================================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}     Enterprise PII Guardrails - 1-Click GCP Deployment Wizard    ${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo ""

# 1. Verify gcloud CLI availability
if ! command -v gcloud >/dev/null 2>&1; then
    echo -e "${RED}Error: 'gcloud' CLI is not installed or not in PATH.${NC}"
    echo "Please install Google Cloud SDK or launch this script in Google Cloud Shell."
    exit 1
fi

# 2. Check active GCP Project
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || true)
if [ -z "$CURRENT_PROJECT" ] || [ "$CURRENT_PROJECT" = "(unset)" ]; then
    echo -e "${YELLOW}No active GCP project is currently set.${NC}"
    read -rp "Enter your Google Cloud Project ID: " INPUT_PROJECT
    if [ -z "$INPUT_PROJECT" ]; then
        echo -e "${RED}Project ID is required. Exiting.${NC}"
        exit 1
    fi
    gcloud config set project "$INPUT_PROJECT"
    CURRENT_PROJECT="$INPUT_PROJECT"
fi

echo -e "Target GCP Project: ${GREEN}${CURRENT_PROJECT}${NC}"
echo ""

# 3. Prompt user configurations with enterprise defaults
read -rp "Enter Admin Studio Password (min 8 chars, default: Admin@12345): " ADMIN_PASS_INPUT
ADMIN_PASSWORD=${ADMIN_PASS_INPUT:-Admin@12345}

read -rp "Enter Company / Organization Name (default: GCP Demo): " COMPANY_INPUT
COMPANY_NAME=${COMPANY_INPUT:-GCP Demo}

read -rp "Enter GCP Zone (default: us-central1-a): " ZONE_INPUT
ZONE=${ZONE_INPUT:-us-central1-a}

read -rp "Enter Machine Type (default: e2-standard-2 [2 vCPU, 8GB RAM]): " MACHINE_INPUT
MACHINE_TYPE=${MACHINE_INPUT:-e2-standard-2}

INSTANCE_NAME="piiguardrail-gce"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTUP_SCRIPT="${SCRIPT_DIR}/startup-script.sh"

if [ ! -f "$STARTUP_SCRIPT" ]; then
    echo -e "${RED}Error: Startup script not found at ${STARTUP_SCRIPT}${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}--- Deployment Summary ---${NC}"
echo -e "Project:      ${GREEN}${CURRENT_PROJECT}${NC}"
echo -e "Instance:     ${GREEN}${INSTANCE_NAME}${NC}"
echo -e "Zone:         ${GREEN}${ZONE}${NC}"
echo -e "Machine Type: ${GREEN}${MACHINE_TYPE}${NC}"
echo -e "Company Name: ${GREEN}${COMPANY_NAME}${NC}"
echo -e "${CYAN}--------------------------${NC}"
echo ""

# 4. Check / create firewall rule for port 8000
FIREWALL_RULE="allow-piiguardrails-8000"
echo -e "Checking firewall rule ${CYAN}${FIREWALL_RULE}${NC}..."
if ! gcloud compute firewall-rules describe "$FIREWALL_RULE" >/dev/null 2>&1; then
    echo -e "Creating firewall rule ${GREEN}${FIREWALL_RULE}${NC} for port 8000..."
    gcloud compute firewall-rules create "$FIREWALL_RULE" \
        --direction=INGRESS \
        --priority=1000 \
        --network=default \
        --action=ALLOW \
        --rules=tcp:8000 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=piiguardrails \
        --description="Allow inbound traffic to Enterprise PII Guardrails Studio"
else
    echo -e "Firewall rule ${GREEN}${FIREWALL_RULE}${NC} already exists."
fi

# 5. Provision Compute Engine Virtual Machine
echo ""
echo -e "${CYAN}Launching Compute Engine VM '${INSTANCE_NAME}'...${NC}"
gcloud compute instances create "$INSTANCE_NAME" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image-family=ubuntu-2404-lts-amd64 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server,piiguardrails \
    --metadata=company_name="${COMPANY_NAME}",gui_password="${ADMIN_PASSWORD}" \
    --metadata-from-file=startup-script="$STARTUP_SCRIPT"

# 6. Retrieve VM External IP
EXTERNAL_IP=$(gcloud compute instances describe "$INSTANCE_NAME" \
    --zone="$ZONE" \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo -e "${GREEN}==================================================================${NC}"
echo -e "${GREEN}      Enterprise PII Guardrails VM Successfully Created!         ${NC}"
echo -e "${GREEN}==================================================================${NC}"
echo ""
echo -e "External IP Address: ${CYAN}${EXTERNAL_IP}${NC}"
echo -e "Studio Web UI:       ${CYAN}http://${EXTERNAL_IP}:8000${NC}"
echo -e "OpenAPI Specs:       ${CYAN}http://${EXTERNAL_IP}:8000/docs${NC}"
echo -e "Default Username:    ${CYAN}admin${NC}"
echo -e "Password:            ${CYAN}${ADMIN_PASSWORD}${NC}"
echo ""
echo -e "${YELLOW}Note: The instance is currently executing the startup script to install${NC}"
echo -e "${YELLOW}Docker and initialize the database. The Web UI will be fully accessible${NC}"
echo -e "${YELLOW}in approximately 2 to 3 minutes.${NC}"
echo ""
echo -e "To tail live setup progress, run:"
echo -e "  ${CYAN}gcloud compute instances tail-serial-port-output ${INSTANCE_NAME} --zone=${ZONE}${NC}"
echo ""
