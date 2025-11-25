output "namespace" {
  description = "The namespace where resources are deployed"
  value       = kubernetes_namespace.shadow.metadata[0].name
}

output "shadow_enabled" {
  description = "Whether shadow deployment is enabled"
  value       = var.shadow_enabled
}

output "main_service_name" {
  description = "Name of the main service (routes to production)"
  value       = kubernetes_service.app.metadata[0].name
}

output "production_service_name" {
  description = "Name of the production-only service"
  value       = kubernetes_service.production.metadata[0].name
}

output "shadow_service_name" {
  description = "Name of the shadow-only service"
  value       = var.shadow_enabled ? kubernetes_service.shadow[0].metadata[0].name : "N/A"
}

output "istio_injection_enabled" {
  description = "Whether Istio sidecar injection is enabled"
  value       = var.enable_istio_injection
}

output "port_forward_commands" {
  description = "Commands to test the deployments"
  value = {
    production = "kubectl port-forward svc/app-service -n ${var.namespace} 8080:80"
    shadow     = var.shadow_enabled ? "kubectl port-forward svc/app-shadow-service -n ${var.namespace} 8081:80" : "N/A"
  }
}

output "promote_shadow_command" {
  description = "Command to promote shadow to production"
  value       = "terraform apply -var='production_version=${var.shadow_version}' -var='shadow_enabled=false'"
}

output "istio_mirroring_note" {
  description = "Note about enabling Istio mirroring"
  value       = "For traffic mirroring, enable Istio injection and apply istio-mirroring.yaml from manifests directory"
}
