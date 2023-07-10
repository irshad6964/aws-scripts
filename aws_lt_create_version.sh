#!/bin/bash

# Variables
template_id="your-launch-template-id"
new_ami_id="your-new-ami-id"

# Get the current default version of the Launch Template
current_default_version=$(aws ec2 describe-launch-templates --launch-template-ids "$template_id" --query 'LaunchTemplates[0].DefaultVersionNumber' --output text)

# Retrieve the current launch template data
launch_template_data=$(aws ec2 describe-launch-templates --launch-template-ids "$template_id" --query 'LaunchTemplates[0].LaunchTemplateData')

# Create a new version of the Launch Template based on the current default version and modified launch template data
new_template_version=$(aws ec2 create-launch-template-version --launch-template-id "$template_id" --source-version "$current_default_version" --launch-template-data "$launch_template_data" --image-id "$new_ami_id" --version-description "New AMI $(date +'%m/%d/%y')" --query 'LaunchTemplateVersion.VersionNumber' --output text)

# Update the Launch Template to use the new version
aws ec2 modify-launch-template --launch-template-id "$template_id" --default-version "$new_template_version"

echo "Launch Template updated successfully with the new AMI ID and modified launch template data."
