output "namespace" {
  description = "The namespace where resources are deployed"
  value       = kubernetes_namespace.blue_green.metadata[0].name
}

output "active_color" {
  description = "Currently active deployment color"
  value       = var.active_color
}

output "service_name" {
  description = "Name of the Kubernetes service"
  value       = kubernetes_service.app.metadata[0].name
}

output "blue_deployment_name" {
  description = "Name of the blue deployment"
  value       = kubernetes_deployment.blue.metadata[0].name
}

output "green_deployment_name" {
  description = "Name of the green deployment"
  value       = kubernetes_deployment.green.metadata[0].name
}

output "switch_to_green_command" {
  description = "Command to switch traffic to green"
  value       = "terraform apply -var='active_color=green'"
}

output "switch_to_blue_command" {
  description = "Command to switch traffic to blue"
  value       = "terraform apply -var='active_color=blue'"
}
