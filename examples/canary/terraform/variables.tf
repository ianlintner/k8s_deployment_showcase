variable "namespace" {
  description = "Kubernetes namespace for canary deployment"
  type        = string
  default     = "canary-demo"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "showcase-app"
}

variable "stable_replicas" {
  description = "Number of replicas for stable deployment"
  type        = number
  default     = 9
}

variable "canary_replicas" {
  description = "Number of replicas for canary deployment"
  type        = number
  default     = 1
}

variable "canary_enabled" {
  description = "Enable canary deployment"
  type        = bool
  default     = true
}

variable "stable_version" {
  description = "Version for stable deployment"
  type        = string
  default     = "1.0.0"
}

variable "canary_version" {
  description = "Version for canary deployment"
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
