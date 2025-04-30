# -----------------------------------------------------------------------------
# Terraform Configuration for ROSA Classic STS Cluster Deployment
#
# This configuration deploys a Red Hat OpenShift Service on AWS (ROSA)
# classic cluster using AWS STS for authentication.
#
# Prerequisites (MUST be done before terraform apply):
# 1. Terraform CLI (>= 1.4.6) installed.[1, 2, 3, 4]
# 2. AWS CLI installed and configured with appropriate permissions.[5, 6, 2, 3, 7, 4, 8]
# 3. ROSA CLI (`rosa`) installed.[6, 2, 3, 9]
# 4. Valid Red Hat Cloud Services API token (Offline Token).[5, 1, 6, 2, 3, 10, 7, 4, 11, 8, 9]
# 5. Run `rosa login --token=<your_token>`.[5, 2, 10, 7]
# 6. Create Account Roles: `rosa create account-roles --mode auto --yes`.[5, 2, 3, 10, 7]
#    (Note the prefix, default is 'ManagedOpenShift'. Adjust ARNs below if different).
# 7. Create OIDC Config: `rosa create oidc-config --mode auto --yes`.[2, 3, 10]
#    (Find the ID using `rosa list oidc-config` and set `oidc_config_id` variable).[2, 10]
# 8. Create Operator Roles: `rosa create operator-roles --cluster <var.cluster_name> --mode auto --yes`.[2, 3, 10]
#    (Find the exact prefix using `rosa list operator-roles` and set `operator_role_prefix` variable).[2, 10]
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Using version constraint based on user's input
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "~> 1.6" # Using version constraint based on user's input
    }
  }
  required_version = ">= 1.4.6" # Recommended minimum version [1, 2, 3, 4, 8]
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------

# Configure the Red Hat Cloud Services Provider
# Token is best provided via TF_VAR_rhcs_token environment variable or a secure tfvars file [5, 1, 2]
provider "rhcs" {
  token = var.rhcs_token
  url   = var.rhcs_url
}

# Configure the AWS Provider
# Assumes AWS credentials are configured via environment variables,
# shared credentials file (~/.aws/credentials), or IAM instance profile.[12, 13, 14, 5, 1, 6, 15, 2, 3, 16, 7, 17, 18, 4, 8]
provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

# Get current AWS account ID and caller identity ARN
data "aws_caller_identity" "current" {}

# Get default AWS Account Role prefix if not provided
locals {
  # Default prefix used by 'rosa create account-roles --mode auto' [5, 2, 19]
  default_account_role_prefix = "ManagedOpenShift"
  # Use provided prefix if set, otherwise use the default
  account_role_prefix = coalesce(var.account_role_prefix, local.default_account_role_prefix)
}

# -----------------------------------------------------------------------------
# ROSA Cluster Resource
# -----------------------------------------------------------------------------

resource "rhcs_cluster_rosa_classic" "rosa_cluster" {
  name                 = var.cluster_name
  cloud_region         = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  availability_zones   = var.availability_zones
  multi_az             = var.multi_az
  version              = var.openshift_version
  compute_machine_type = var.compute_machine_type
  replicas             = var.compute_nodes
  private              = var.private
  tags                 = var.tags

  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn # Track who created the cluster via Terraform
  }

  # --- STS Configuration Block ---
  # This block is MANDATORY for STS clusters and tells RHCS which pre-created
  # IAM roles and OIDC config to use.[9, 20, 21, 22]
  sts = {
    # OIDC Config ID created by 'rosa create oidc-config --mode auto'
    # MUST be provided via variable 'oidc_config_id' [9, 20]
    oidc_config_id = var.oidc_config_id

    # Operator Role Prefix created by 'rosa create operator-roles --cluster <name>...'
    # MUST be provided via variable 'operator_role_prefix' [9, 20]
    operator_role_prefix = var.operator_role_prefix

    # Account Role ARNs created by 'rosa create account-roles...'
    # Assumes default prefix 'ManagedOpenShift' unless 'account_role_prefix' variable is set.
    # Verify these roles exist in your AWS account.[9, 20]
    # Using 'aws' partition directly as aws_caller_identity doesn't expose partition.
    role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.account_role_prefix}-Installer-Role"
    support_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.account_role_prefix}-Support-Role"
    instance_iam_roles = {
      master_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.account_role_prefix}-ControlPlane-Role"
      worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.account_role_prefix}-Worker-Role"
    }

    # Optional: Specify if using an AWS Permissions Boundary
    # permissions_boundary = var.permissions_boundary_arn
  }
  # --- End STS Block ---

  # Optional: Specify existing subnet IDs if deploying into an existing VPC
  # aws_subnet_ids = var.aws_subnet_ids

  # Optional: Lifecycle and timeouts
  # lifecycle {
  #   prevent_destroy = true
  # }
  # timeouts {
  #   create = "90m"
  #   delete = "60m"
  # }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "cluster_id" {
  description = "The unique identifier of the ROSA cluster."
  value       = rhcs_cluster_rosa_classic.rosa_cluster.id
}

output "cluster_name" {
  description = "The name of the ROSA cluster."
  value       = rhcs_cluster_rosa_classic.rosa_cluster.name
}

output "cluster_api_url" {
  description = "The API endpoint URL for the ROSA cluster."
  value       = rhcs_cluster_rosa_classic.rosa_cluster.api_url
  sensitive   = false # API URL is typically not sensitive, but consider your security policy
}

output "cluster_console_url" {
  description = "The web console URL for the ROSA cluster."
  value       = rhcs_cluster_rosa_classic.rosa_cluster.console_url
}

output "cluster_state" {
  description = "Current state of the ROSA cluster (e.g., 'ready', 'installing')."
  value       = rhcs_cluster_rosa_classic.rosa_cluster.state
}

output "sts_operator_role_prefix_used" {
  description = "The Operator Role Prefix used in the STS configuration."
  value       = rhcs_cluster_rosa_classic.rosa_cluster.sts.operator_role_prefix
}

output "sts_oidc_config_id_used" {
  description = "The OIDC Config ID used in the STS configuration."
  value       = rhcs_cluster_rosa_classic.rosa_cluster.sts.oidc_config_id
}
