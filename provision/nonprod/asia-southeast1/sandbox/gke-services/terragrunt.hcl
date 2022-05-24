# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # GCP: Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  project_id = local.project_vars.locals.project_id
  gcp_region = local.region_vars.locals.gcp_region
  metadata   = yamldecode(file(find_in_parent_folders("metadata.yaml")))
}
# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/phuongnd96/gke-services.git//?ref=0.0.1"
}

// // Variables to pass into the module
inputs = {
  project_id                          = "${local.project_id}"
  cluster_name                        = "zonal-${local.metadata.master_prefix}-${local.environment_vars.locals.environment}-gke"
  region                              = "${local.gcp_region}"
  cluster_zone                        = "asia-southeast1-a"
  deploy_grafana                      = true
  grafana_chart_version               = "6.29.3"
  grafana_chart_repository            = "https://grafana.github.io/helm-charts"
  grafana_chart                       = "grafana"
  grafana_ns                          = "monitoring"
  grafana_helm_override = [
    {
      name  = "ingress.enabled",
      value = true
    }
  ]
  deploy_nginx_ingress                = true
  nginx_ingress_chart_version         = "4.1.2"
  nginx_ingress_chart_repository      = "https://kubernetes.github.io/ingress-nginx"
  nginx_ingress_chart                 = "ingress-nginx"
  nginx_ingress_ns                    = "ingress-nginx"
}
