variable "namespace" {
  description = "Kubernetes namespace for A/B testing deployment"
  type        = string
  default     = "ab-testing-demo"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "showcase-app"
}

variable "version_a_replicas" {
  description = "Number of replicas for version A (control)"
  type        = number
  default     = 3
}

variable "version_b_replicas" {
  description = "Number of replicas for version B (variant)"
  type        = number
  default     = 3
}

variable "version_a_enabled" {
  description = "Enable version A deployment"
  type        = bool
  default     = true
}

variable "version_b_enabled" {
  description = "Enable version B deployment"
  type        = bool
  default     = true
}

variable "version_a_label" {
  description = "Label for version A"
  type        = string
  default     = "A"
}

variable "version_b_label" {
  description = "Label for version B"
  type        = string
  default     = "B"
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
