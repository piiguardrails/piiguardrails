variable "project_id" {
  type        = string
  description = "The Google Cloud project ID where resources will be provisioned."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for deployment."
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP zone for the virtual machine instance."
}

variable "instance_name" {
  type        = string
  default     = "piiguardrail-gce"
  description = "Name of the Compute Engine instance."
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Compute Engine machine type (minimum: e2-standard-2, 2 vCPU, 8GB RAM)."
}

variable "disk_size_gb" {
  type        = number
  default     = 30
  description = "Size of the persistent boot disk in GB."
}

variable "network" {
  type        = string
  default     = "default"
  description = "VPC network name to attach the VM."
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Master password for the Studio Web UI (username: admin, min 8 characters)."
}

variable "company_name" {
  type        = string
  default     = "GCP Demo"
  description = "Company or organization name for white-labeling the Web Studio and Reports."
}

variable "brand_logo_url" {
  type        = string
  default     = ""
  description = "Optional URL to company logo (PNG/SVG) for white-labeling."
}

variable "license_key" {
  type        = string
  default     = ""
  description = "Optional preconfigured commercial license key. Leave blank for automatic 10,000 requests evaluation."
}

variable "app_port" {
  type        = string
  default     = "8000"
  description = "Port to expose the Enterprise PII Guardrails Studio."
}

variable "allowed_inbound_cidr" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR IP blocks permitted to access port 8000."
}
