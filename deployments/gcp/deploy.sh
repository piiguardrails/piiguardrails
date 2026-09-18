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

# 3. Prompt user configurations (Mandatory password with zero default)
while true; do
    read -s -rp "Enter Admin Studio Password (min 8 chars, mandatory): " ADMIN_PASSWORD
    echo ""
    if [ ${#ADMIN_PASSWORD} -lt 8 ]; then
        echo -e "${RED}Error: Password must be at least 8 characters long.${NC}"
        continue
    fi
    read -s -rp "Confirm Admin Studio Password: " ADMIN_PASS_CONFIRM
    echo ""
    if [ "$ADMIN_PASSWORD" != "$ADMIN_PASS_CONFIRM" ]; then
        echo -e "${RED}Error: Passwords do not match. Please try again.${NC}"
        continue
    fi
    break
done

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

# 4. Ensure Compute Engine API is enabled
echo -e "Ensuring Compute Engine API (${CYAN}compute.googleapis.com${NC}) is enabled..."
gcloud services enable compute.googleapis.com --quiet

# 5. Check / create firewall rule for port 8000
FIREWALL_RULE="allow-piiguardrails-8000"
echo -e "Checking firewall rule ${CYAN}${FIREWALL_RULE}${NC}..."
if ! gcloud compute firewall-rules describe "$FIREWALL_RULE" --quiet >/dev/null 2>&1; then
    echo -e "Creating firewall rule ${GREEN}${FIREWALL_RULE}${NC} for port 8000..."
    gcloud compute firewall-rules create "$FIREWALL_RULE" \
        --quiet \
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
    --quiet \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image-family=ubuntu-2404-lts-amd64 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server,piiguardrails \
    --metadata=company_name="${COMPANY_NAME}",gui_password="${ADMIN_PASSWORD}",license_key="ED4-AQAGWNU7FAAAAJYQ-AAAAAAAAAAAAAKFI-VXRAU4YPAHXPW6JD-CRJIDR5NFJ4ITZA2-ICFCAEEV7OYVNWO7-JDSSZ5RMIUNDHULQ-DMZPYP4ICOFTJF53-AMKICAI6R57R4XM4-QYR4UGEQ4ZTP3DAM" \
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
echo -e "License Included:    ${GREEN}10,000 requests evaluation license active${NC}"
echo ""
echo -e "${YELLOW}Waiting for Web Studio to finish startup (~90-120 seconds)...${NC}"
READY=false
for i in $(seq 1 40); do
    if curl -s -f -m 3 "http://${EXTERNAL_IP}:8000/health" >/dev/null 2>&1; then
        READY=true
        break
    fi
    printf "${CYAN}.${NC}"
    sleep 5
done
echo ""

if [ "$READY" = "true" ]; then
    echo ""
    echo -e "${GREEN}==================================================================${NC}"
    echo -e "${GREEN}   Enterprise PII Guardrails is LIVE and Ready for Access!        ${NC}"
    echo -e "${GREEN}==================================================================${NC}"
    echo ""
    echo -e "  Direct Web Studio: ${CYAN}http://${EXTERNAL_IP}:8000${NC}"
    echo -e "  Interactive Specs: ${CYAN}http://${EXTERNAL_IP}:8000/docs${NC}"
    echo -e "  Username:          ${CYAN}admin${NC}"
    echo -e "  Password:          ${CYAN}${ADMIN_PASSWORD}${NC}"
    echo ""
    echo -e "${GREEN}==================================================================${NC}"
else
    echo ""
    echo -e "${YELLOW}Notice: Instance is still completing initial setup in the background.${NC}"
    echo -e "Your application will be live shortly at: ${CYAN}http://${EXTERNAL_IP}:8000${NC}"
    echo -e "To view your live instance IP anytime, run:"
    echo -e "  ${CYAN}gcloud compute instances list${NC}"
    echo ""
fi
