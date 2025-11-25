variable "namespace" {
  description = "Kubernetes namespace for shadow/mirroring deployment"
  type        = string
  default     = "shadow-demo"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "showcase-app"
}

variable "production_replicas" {
  description = "Number of replicas for production deployment"
  type        = number
  default     = 3
}

variable "shadow_replicas" {
  description = "Number of replicas for shadow deployment"
  type        = number
  default     = 3
}

variable "shadow_enabled" {
  description = "Enable shadow deployment"
  type        = bool
  default     = true
}

variable "production_version" {
  description = "Version for production deployment"
  type        = string
  default     = "1.0.0"
}

variable "shadow_version" {
  description = "Version for shadow deployment"
  type        = string
  default     = "2.0.0"
}

variable "image_repository" {
  description = "Container image repository"
  type        = string
  default     = "nginx"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "1.25-alpine"
}

variable "enable_istio_injection" {
  description = "Enable Istio sidecar injection"
  type        = bool
  default     = false
}
