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
  gcp_region   = local.region_vars.locals.gcp_region
  metadata = yamldecode(file(find_in_parent_folders("metadata.yaml")))
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
  source = "git::https://github.com/terraform-google-modules/terraform-google-network.git//?ref=v5.0.0"
}

// // Variables to pass into the module
inputs = {
  project_id = local.project_id
  name = "${local.metadata.master_prefix}-${local.environment_vars.locals.environment}-gke"
  network_name = "${local.metadata.master_prefix}-${local.environment_vars.locals.environment}-network"
  subnets = [
    {
      subnet_name           = "gke-subnet-${local.gcp_region}"
      subnet_ip             = "10.0.0.0/17"
      subnet_region         = local.gcp_region
      subnet_private_access = "false"
    }
  ]
  secondary_ranges = {
    "gke-subnet-${local.gcp_region}" = [
      // limit to 40 secondary cidr block per subnet
      {
        range_name    = "ip-range-pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "ip-range-scv"
        ip_cidr_range = "192.168.64.0/18"
      }
    ]
  }

}