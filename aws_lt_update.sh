#!/bin/bash

# Variables
template_id="your-launch-template-id"
new_ami_id="your-new-ami-id"

# Update Launch Template
aws ec2 modify-launch-template --launch-template-id "$template_id" --image-id "$new_ami_id"

echo "Launch Template updated successfully with the new AMI ID."
