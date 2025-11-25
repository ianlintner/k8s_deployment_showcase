variable "namespace" {
  description = "Kubernetes namespace for rolling update deployment"
  type        = string
  default     = "rolling-update-demo"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "showcase-app"
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 4
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "max_surge" {
  description = "Maximum number of pods that can be created above desired during update. Can be an absolute number (e.g., '1') or a percentage (e.g., '25%')."
  type        = string
  default     = "1"
}

variable "max_unavailable" {
  description = "Maximum number of pods that can be unavailable during update. Can be an absolute number (e.g., '1') or a percentage (e.g., '25%')."
  type        = string
  default     = "1"
}

variable "min_ready_seconds" {
  description = "Minimum time a pod should be ready before available"
  type        = number
  default     = 5
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
