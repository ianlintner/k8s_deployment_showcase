output "namespace" {
  description = "The namespace where resources are deployed"
  value       = kubernetes_namespace.canary.metadata[0].name
}

output "canary_enabled" {
  description = "Whether canary deployment is enabled"
  value       = var.canary_enabled
}

output "traffic_ratio" {
  description = "Traffic distribution (stable:canary)"
  value       = var.canary_enabled ? "${var.stable_replicas}:${var.canary_replicas}" : "${var.stable_replicas}:0"
}

output "canary_percentage" {
  description = "Approximate percentage of traffic to canary"
  value       = var.canary_enabled && (var.stable_replicas + var.canary_replicas) > 0 ? "${floor(var.canary_replicas * 100 / (var.stable_replicas + var.canary_replicas))}%" : "0%"
}

output "service_name" {
  description = "Name of the main Kubernetes service"
  value       = kubernetes_service.app.metadata[0].name
}

output "stable_service_name" {
  description = "Name of the stable-only service"
  value       = kubernetes_service.stable.metadata[0].name
}

output "canary_service_name" {
  description = "Name of the canary-only service"
  value       = var.canary_enabled ? kubernetes_service.canary[0].metadata[0].name : "N/A"
}

output "increase_canary_command" {
  description = "Command to increase canary traffic"
  value       = "terraform apply -var='stable_replicas=7' -var='canary_replicas=3'"
}

output "full_rollout_command" {
  description = "Command for full rollout to canary"
  value       = "terraform apply -var='stable_replicas=0' -var='canary_replicas=10'"
}
