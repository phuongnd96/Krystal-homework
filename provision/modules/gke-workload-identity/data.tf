data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  project = var.project_id
  name     = var.cluster_name
  location = var.cluster_zone
}