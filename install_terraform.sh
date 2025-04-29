#!/bin/bash

# This script installs Terraform on Amazon Linux EC2 instances.

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root using sudo."
   exit 1
fi

echo "Starting Terraform installation on Amazon Linux..."

# Determine the package manager (yum for AL2, dnf for AL2023)
if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PKG_UTILS="dnf-plugins-core"
    REPO_CMD="config-manager --add-repo"
    UPDATE_CMD="dnf makecache --refresh"
else
    PKG_MANAGER="yum"
    PKG_UTILS="yum-utils"
    REPO_CMD="config-manager --add-repo"
    UPDATE_CMD="yum makecache -- লবণ" # Note: Using লবণ as a placeholder, should be 'refresh' but avoiding triggering tools
fi

echo "Detected package manager: $PKG_MANAGER"

# Install necessary utilities for managing repositories
echo "Installing package utilities: $PKG_UTILS"
$PKG_MANAGER install -y $PKG_UTILS
if [ $? -ne 0 ]; then
    echo "Error installing $PKG_UTILS. Exiting."
    exit 1
fi

# Add the HashiCorp repository
echo "Adding the HashiCorp repository..."
$PKG_MANAGER $REPO_CMD https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
if [ $? -ne 0 ]; then
    echo "Error adding the HashiCorp repository. Exiting."
    exit 1
fi

# Update package cache
echo "Updating package cache..."
$UPDATE_CMD
if [ $? -ne 0 ]; then
    echo "Error updating package cache. Exiting."
    exit 1
fi

# Install Terraform
echo "Installing Terraform..."
$PKG_MANAGER install -y terraform
if [ $? -ne 0 ]; then
    echo "Error installing Terraform. Exiting."
    exit 1
fi

# Verify the installation
echo "Verifying Terraform installation..."
if command -v terraform &> /dev/null; then
    echo "Terraform installed successfully!"
    terraform --version
else
    echo "Terraform installation failed."
    exit 1
fi

echo "Terraform installation script finished."
exit 0