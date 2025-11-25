output "namespace" {
  description = "The namespace where resources are deployed"
  value       = kubernetes_namespace.rolling_update.metadata[0].name
}

output "deployment_name" {
  description = "Name of the deployment"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  description = "Name of the Kubernetes service"
  value       = kubernetes_service.app.metadata[0].name
}

output "current_version" {
  description = "Current application version"
  value       = var.app_version
}

output "strategy_config" {
  description = "Rolling update strategy configuration"
  value = {
    max_surge       = var.max_surge
    max_unavailable = var.max_unavailable
    min_ready_seconds = var.min_ready_seconds
  }
}

output "update_version_command" {
  description = "Command to update to a new version"
  value       = "terraform apply -var='app_version=2.0.0'"
}

output "zero_downtime_config" {
  description = "Command for zero-downtime configuration"
  value       = "terraform apply -var='max_surge=1' -var='max_unavailable=0'"
}
