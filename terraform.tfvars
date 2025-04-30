# --- REQUIRED VALUES ---

# Provide your Red Hat Cloud Services Offline Token
# It's highly recommended to set this via the TF_VAR_rhcs_token environment variable instead of saving it here.
# rhcs_token = "eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0NzQzYTkzMC03YmJiLTRkZGQtOTgzMS00ODcxNGRlZDc0YjUifQ.eyJpYXQiOjE3NDYwMzMxMjEsImp0aSI6ImRiNDJkNTIxLTBkOTQtNDcyMi04YmFkLTgwZWIxMDgxYjM5OCIsImlzcyI6Imh0dHBzOi8vc3NvLnJlZGhhdC5jb20vYXV0aC9yZWFsbXMvcmVkaGF0LWV4dGVybmFsIiwiYXVkIjoiaHR0cHM6Ly9zc28ucmVkaGF0LmNvbS9hdXRoL3JlYWxtcy9yZWRoYXQtZXh0ZXJuYWwiLCJzdWIiOiJmOjUyOGQ3NmZmLWY3MDgtNDNlZC04Y2Q1LWZlMTZmNGZlMGNlNjpyYWtlc2hwYW5keWFsYTk0IiwidHlwIjoiT2ZmbGluZSIsImF6cCI6ImNsb3VkLXNlcnZpY2VzIiwibm9uY2UiOiI3MTBiMDg1OS0zMjUzLTQyY2MtYTIzNi04NzRhOTllMGY3ZTIiLCJzaWQiOiIzYTMwNzQxNy05MWUyLTQ0MTItYjdjNC0zYWU3MTU1ZmVkMzUiLCJzY29wZSI6Im9wZW5pZCBiYXNpYyBhcGkuaWFtLnNlcnZpY2VfYWNjb3VudHMgcm9sZXMgd2ViLW9yaWdpbnMgY2xpZW50X3R5cGUucHJlX2tjMjUgb2ZmbGluZV9hY2Nlc3MifQ.dIExfvEoj0miLtAPJ1qrvdCO-IsQMRlm5DrszbB17fs6VAtoan_nP3CRsu-5egf8RTYISuG658gDXxIQayCQTA" # Example: Keep commented out if using env var

# Cluster Configuration
cluster_name      = "rosa-test-cluster" # Must be <= 15 chars
aws_region        = "us-east-1"         # Choose your desired AWS region
openshift_version = "4.14.9"            # Specify a valid, available version from 'rosa list versions'

# --- REQUIRED STS Configuration ---
# Replace these placeholders with the actual values from your 'rosa create...' prerequisite steps!
operator_role_prefix = "rosa-test-muwy" #!!! REPLACE with output from 'rosa list operator-roles'!!!
oidc_config_id       = "2ig0e61j4dk2g58jak27l2pe38d46tci" #!!! REPLACE with output from 'rosa list oidc-config'!!!

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
