# -----------------------------------------------------------------------------
# Input Variables
# -----------------------------------------------------------------------------

variable "rhcs_token" {
  description = "Red Hat Cloud Services API Token (offline token recommended). Best practice: Set via TF_VAR_rhcs_token environment variable or a secure secrets manager."
  type        = string
  sensitive   = true
}

variable "rhcs_url" {
  description = "Red Hat Cloud Services API URL."
  type        = string
  default     = "https://api.openshift.com"
}

variable "cluster_name" {
  description = "Name for the ROSA cluster (must match name used for 'rosa create operator-roles'). Cannot exceed 15 characters."
  type        = string
  validation {
    condition     = length(var.cluster_name) <= 15
    error_message = "Cluster name cannot exceed 15 characters."
  }
}

variable "aws_region" {
  description = "AWS region where the cluster will be deployed."
  type        = string
}

variable "openshift_version" {
  description = "Desired OpenShift version for the cluster (e.g., '4.14.9'). Use `rosa list versions` to see available versions."
  type        = string
  # Example: default = "4.14.9" # Set a specific default or fetch dynamically if needed
}

variable "compute_machine_type" {
  description = "EC2 instance type for the compute nodes."
  type        = string
  default     = "m5.xlarge"
}

variable "compute_nodes" {
  description = "Number of compute nodes for the cluster's default machine pool. Minimum 2 for single-AZ, 3 for multi-AZ."
  type        = number
  default     = 2 # Adjust based on multi_az setting
}

variable "availability_zones" {
  description = "List of Availability Zones for the default machine pool. If empty, ROSA selects defaults. For multi-AZ, provide 3 zones."
  type        = list(string)
  default     =
  # Example for multi-AZ: default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "multi_az" {
  description = "Deploy the cluster across multiple Availability Zones (requires 3 AZs and compute_nodes >= 3)."
  type        = bool
  default     = false # Recommended for production
}

variable "private" {
  description = "Enable private API endpoint and private application routing (requires AWS PrivateLink setup)."
  type        = bool
  default     = false
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

# --- STS Specific Variables ---

variable "operator_role_prefix" {
  description = "REQUIRED: Prefix for the Operator IAM Roles created by 'rosa create operator-roles --cluster <name>...'. Find using 'rosa list operator-roles'."
  type        = string
  # Example: "my-rosa-cluster-abcd" # Replace with your actual prefix
}

variable "oidc_config_id" {
  description = "REQUIRED: ID of the OIDC configuration created by 'rosa create oidc-config --mode auto'. Find using 'rosa list oidc-config'."
  type        = string
  # Example: "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" # Replace with your actual ID
}

variable "account_role_prefix" {
  description = "Optional: Prefix used for Account Roles if different from the default 'ManagedOpenShift'. Must match the prefix used during 'rosa create account-roles'."
  type        = string
  default     = null # Defaults to 'ManagedOpenShift' in main.tf locals if null
}

# variable "permissions_boundary_arn" {
#   description = "Optional: ARN of the IAM Permissions Boundary policy to apply to STS roles."
#   type        = string
#   default     = null
# }

# variable "aws_subnet_ids" {
#   description = "Optional: List of existing AWS Subnet IDs to deploy the cluster into (required if not creating a new VPC)."
#   type        = list(string)
#   default     = null
# }
