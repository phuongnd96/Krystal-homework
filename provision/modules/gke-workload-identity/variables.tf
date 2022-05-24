variable "cluster_name" {
  description = "A cluster name"
  default     = ""
}

variable "cluster_zone" {
  description = "A cluster zone"
  default     = ""
}

variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "namespace" {
  description = "Namespace for the Kubernetes service account"
  type        = string
  default     = "default"
}

variable "name" {
  description = "Name for both service accounts. The GCP SA will be truncated to the first 30 chars if necessary."
  type        = string
}

variable "roles" {
  description = "A list of roles to be added to the created service account"
  type        = list(string)
  default     = []
}