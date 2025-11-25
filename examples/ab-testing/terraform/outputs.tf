output "namespace" {
  description = "The namespace where resources are deployed"
  value       = kubernetes_namespace.ab_testing.metadata[0].name
}

output "version_a_enabled" {
  description = "Whether version A is enabled"
  value       = var.version_a_enabled
}

output "version_b_enabled" {
  description = "Whether version B is enabled"
  value       = var.version_b_enabled
}

output "combined_service_name" {
  description = "Name of the combined service"
  value       = kubernetes_service.app.metadata[0].name
}

output "version_a_service_name" {
  description = "Name of the version A service"
  value       = var.version_a_enabled ? kubernetes_service.version_a[0].metadata[0].name : "N/A"
}

output "version_b_service_name" {
  description = "Name of the version B service"
  value       = var.version_b_enabled ? kubernetes_service.version_b[0].metadata[0].name : "N/A"
}

output "test_commands" {
  description = "Commands to test A/B routing"
  value = {
    test_version_a         = "curl http://localhost:8080"
    test_version_b_header  = "curl -H 'X-Version: B' http://localhost:8080"
    test_version_b_cookie  = "curl -b 'ab_test=version-b' http://localhost:8080"
    port_forward_a         = "kubectl port-forward svc/app-service-a -n ${var.namespace} 8080:80"
    port_forward_b         = "kubectl port-forward svc/app-service-b -n ${var.namespace} 8081:80"
  }
}

output "rollout_winner_b_command" {
  description = "Command to roll out version B as winner"
  value       = "terraform apply -var='version_a_enabled=false' -var='version_b_replicas=6'"
}
