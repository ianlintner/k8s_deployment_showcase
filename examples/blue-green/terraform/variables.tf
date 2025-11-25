variable "namespace" {
  description = "Kubernetes namespace for blue-green deployment"
  type        = string
  default     = "blue-green-demo"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "showcase-app"
}

variable "blue_replicas" {
  description = "Number of replicas for blue deployment"
  type        = number
  default     = 3
}

variable "green_replicas" {
  description = "Number of replicas for green deployment"
  type        = number
  default     = 3
}

variable "blue_version" {
  description = "Version for blue deployment"
  type        = string
  default     = "1.0.0"
}

variable "green_version" {
  description = "Version for green deployment"
  type        = string
  default     = "2.0.0"
}

variable "active_color" {
  description = "Active deployment color (blue or green)"
  type        = string
  default     = "blue"

  validation {
    condition     = contains(["blue", "green"], var.active_color)
    error_message = "Active color must be 'blue' or 'green'."
  }
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
