# --- REQUIRED VALUES ---

# Provide your Red Hat Cloud Services Offline Token
# It's highly recommended to set this via the TF_VAR_rhcs_token environment variable instead of saving it here.
# rhcs_token = "eyJhbGciOiJ..." # Example: Keep commented out if using env var

# Cluster Configuration
cluster_name      = "rosa-test-cluster" # Must be <= 15 chars
aws_region        = "us-east-1"         # Choose your desired AWS region
openshift_version = "4.14.9"            # Specify a valid, available version from 'rosa list versions'

# --- REQUIRED STS Configuration ---
# Replace these placeholders with the actual values from your 'rosa create...' prerequisite steps!
operator_role_prefix = "rosa-test-cluster-abcd" #!!! REPLACE with output from 'rosa list operator-roles'!!!
oidc_config_id       = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" #!!! REPLACE with output from 'rosa list oidc-config'!!!

# --- Optional Cluster Configuration ---

# Compute Node Configuration (Adjust based on multi_az)
compute_nodes = 2 # Use 3 or more for multi_az=true
multi_az      = false

# Specify Availability Zones if needed (required for multi_az=true)
# availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Set to true for a private cluster (requires PrivateLink setup)
# private = true

# Optional: Override default tags
# tags = {
#   Environment = "Production"
#   CostCenter  = "IT-Platform"
# }

# Optional: Specify if you used a custom prefix for account roles
# account_role_prefix = "my-custom-prefix"

# Optional: Specify if deploying into an existing VPC
# aws_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy", "subnet-zzzzzzzzzzzzzzzzz"]
