terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "allow_piiguardrails" {
  name    = "allow-piiguardrails-8000"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = [var.app_port]
  }

  source_ranges = var.allowed_inbound_cidr
  target_tags   = ["piiguardrails"]
  description   = "Inbound access to Enterprise PII Guardrails Studio Web UI and REST API"
}

resource "google_compute_instance" "piiguardrail_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server", "piiguardrails"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = var.network
    access_config {
      # Ephemeral public IP assigned automatically
    }
  }

  metadata = {
    gui_password = var.admin_password
    company_name = var.company_name
    brand_logo   = var.brand_logo_url
    license_key  = var.license_key
    app_port     = var.app_port
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")

  service_account {
    scopes = ["cloud-platform"]
  }
}
