output "instance_external_ip" {
  description = "Public external IP address of the Enterprise PII Guardrails Compute Engine VM."
  value       = google_compute_instance.piiguardrail_vm.network_interface[0].access_config[0].nat_ip
}

output "studio_web_ui_url" {
  description = "URL to access the Enterprise PII Guardrails Studio Web UI."
  value       = "http://${google_compute_instance.piiguardrail_vm.network_interface[0].access_config[0].nat_ip}:${var.app_port}"
}

output "openapi_docs_url" {
  description = "URL to access the interactive OpenAPI documentation."
  value       = "http://${google_compute_instance.piiguardrail_vm.network_interface[0].access_config[0].nat_ip}:${var.app_port}/docs"
}

output "admin_username" {
  description = "Default administrative username."
  value       = "admin"
}
