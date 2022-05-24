provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  
}

locals {
  gcp_sa_email = google_service_account.cluster_service_account.email
  k8s_sa_gcp_derived_name = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.name}]"
  gcp_sa_fqn     = "serviceAccount:${local.gcp_sa_email}"
}

resource "google_service_account" "cluster_service_account" {
  account_id   = substr(var.name, 0, 30)
  display_name = substr("GCP SA bound to K8S SA ${var.name}", 0, 100)
  project      = var.project_id
}

resource "google_service_account_iam_member" "main" {
  service_account_id = google_service_account.cluster_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.k8s_sa_gcp_derived_name
}

resource "google_project_iam_member" "workload_identity_sa_bindings" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = local.gcp_sa_fqn
}



