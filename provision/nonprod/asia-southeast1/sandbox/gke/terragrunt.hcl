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
  source = "git::https://github.com/phuongnd96/simple-gke.git//?ref=0.0.4"
}

// // Variables to pass into the module
inputs = {
  project_id                  = "${local.project_id}"
  name                        = "zonal-${local.metadata.master_prefix}-${local.environment_vars.locals.environment}-gke"
  region                      = "${local.gcp_region}"
  zones                       = ["asia-southeast1-a","asia-southeast1-b"]
  network                     = "${local.metadata.master_prefix}-${local.environment_vars.locals.environment}-network"
  subnetwork                  = "gke-subnet-${local.gcp_region}"
  pods_secondary_ip_range_name  = "ip-range-pods"
  services_secondary_range_name = "ip-range-scv"
  remove_default_node_pool    = true
  nodes_per_az = 1
  create_cluster_admin_role_for_users = true
  admin_users = [
    {
        name= "career.phuongnguyen@gmail.com"
    }
  ]
}
