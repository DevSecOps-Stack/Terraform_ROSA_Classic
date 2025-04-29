# -----------------------------------------------------------------------------
# Terraform Configuration for ROSA Cluster Deployment
#
# This configuration deploys a Red Hat OpenShift Service on AWS (ROSA)
# classic cluster using the official RHCS Terraform provider.
#
# Prerequisites:
# 1. Terraform CLI installed.
# 2. AWS CLI installed and configured with appropriate permissions.
# 3. ROSA CLI (`rosa`) installed and configured.
# 4. Red Hat Cloud Services API token.
# 5. Run `rosa login` to authenticate.
# 6. Create the necessary Account Roles: `rosa create account-roles --mode auto --yes`
# 7. Create the OIDC provider and Operator Roles *before* applying this Terraform config:
#    `rosa create oidc-config --mode auto --yes`
#    `rosa create operator-roles --cluster <your-cluster-name> --mode auto --yes`
#    (Replace <your-cluster-name> with the value of `var.cluster_name`)
#    Note: The Operator Roles prefix will be derived from your cluster name.
#          Ensure the `operator_role_prefix` variable matches if you created them manually
#          with a different prefix.
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
    rhcs = {
      version = "1.6.8"
      source  = "terraform-redhat/rhcs"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------

# Configure the Red Hat Cloud Services Provider
# The token can also be provided via the RHCS_TOKEN environment variable.
provider "rhcs" {
  token = var.rhcs_token
  url   = var.rhcs_url # Optional: Defaults to https://api.openshift.com
}

# Configure the AWS Provider
# Assumes AWS credentials are configured via environment variables,
# shared credentials file, or IAM instance profile.
provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Input Variables
# -----------------------------------------------------------------------------

variable "rhcs_token" {
  description = "Red Hat Cloud Services API Token (offline token recommended)."
  type        = string
  sensitive   = true
  # Best practice: Set this via an environment variable (TF_VAR_rhcs_token) or a .tfvars file.
}

variable "rhcs_url" {
  description = "Red Hat Cloud Services API URL."
  type        = string
  default     = "https://api.openshift.com"
}

variable "cluster_name" {
  description = "Name for the ROSA cluster."
  type        = string
  default     = "my-rosa-cluster"
}

variable "aws_region" {
  description = "AWS region where the cluster will be deployed."
  type        = string
  default     = "us-east-1"
}

# --- Corrected Variable Name ---
variable "openshift_version" {
  description = "Desired OpenShift version for the cluster (e.g., '4.14.9'). Use `rosa list versions` to see available versions."
  type        = string
  default     = "4.14.9"
  # It's best to explicitly set this or fetch the latest stable version dynamically if needed.
}
# --- End Correction ---


variable "compute_machine_type" {
  description = "EC2 instance type for the compute nodes."
  type        = string
  default     = "m5.xlarge"
}

variable "compute_nodes" {
  description = "Number of compute nodes for the cluster (minimum 2 for multi-AZ)."
  type        = number
  default     = 1 # Must be a multiple of the number of availability zones (usually 3 for default ROSA) if using multi-AZ
}

variable "availability_zones" {
  description = "List of Availability Zones to deploy the cluster into."
  type        = list(string)
  default     = ["us-east-1a"] # If empty, ROSA will select default AZs for the region. e.g., ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "multi_az" {
  description = "Deploy the cluster across multiple Availability Zones."
  type        = bool
  default     = false # Recommended for production
}

variable "private" {
  description = "Enable private API endpoint and private application routing (AWS PrivateLink)."
  type        = bool
  default     = false # Set to true if you need PrivateLink access
}

variable "tags" {
  description = "Tags to apply to the cluster and associated AWS resources."
  type        = map(string)
  default = {
    "Environment" = "Development"
    "Project"     = "ROSA Deployment"
    "ManagedBy"   = "Terraform"
  }
}

# Note: OIDC Config ID and Operator Role Prefix are derived from prerequisite steps
# using the `rosa` CLI. Ensure these match the outputs from those commands.
# You might need to fetch these dynamically or pass them as variables if needed.
# The `rhcs` provider assumes these roles/configs exist based on naming conventions
# derived from the cluster name if not explicitly provided.

# variable "operator_role_prefix" {
#   description = "Prefix for the Operator IAM Roles created by `rosa create operator-roles`."
#   type        = string
#   # Example: default = "my-rosa-cluster-abcd" # Usually derived from cluster name + random suffix
# }

# variable "oidc_config_id" {
#   description = "ID of the OIDC configuration created by `rosa create oidc-config`."
#   type        = string
# }


# -----------------------------------------------------------------------------
# ROSA Cluster Resource
# -----------------------------------------------------------------------------

resource "rhcs_cluster_rosa_classic" "rosa_cluster" {
  name                 = var.cluster_name
  cloud_region         = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  # aws_subnet_ids     = [] # Optional: Specify existing subnet IDs if deploying into an existing VPC
  availability_zones   = var.availability_zones # Optional: Specify AZs, otherwise defaults are used
  multi_az             = var.multi_az
  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn # Track who created the cluster via Terraform
  }

  # --- Corrected Version Attribute ---
  version              = var.openshift_version # Specify the desired OpenShift version string directly
  # --- End Correction ---

  compute_machine_type = var.compute_machine_type
  replicas             = var.compute_nodes # Set desired number of compute nodes
  tags                 = var.tags
  private              = var.private # Use 'private' instead of 'private_link'


  # If you created operator roles with a specific prefix different from the cluster name,
  # specify it here. Otherwise, the provider derives it.
  # operator_role_prefix = var.operator_role_prefix

  # If you created the OIDC config manually and need to specify its ID:
  # oidc_config_id = var.oidc_config_id

  # Note: The provider implicitly uses the account roles created via `rosa create account-roles`.
  # Ensure these roles exist in the AWS account.

  # lifecycle {
  #   # Prevent accidental deletion of the cluster without explicit confirmation
  #   prevent_destroy = true
  # }

  # timeouts {
  #   create = "90m" # Allow ample time for cluster creation
  #   delete = "60m" # Allow time for cluster deletion
  # }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

# Get current AWS account ID and caller identity ARN
data "aws_caller_identity" "current" {}

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
