#!/bin/bash

# Variables
instance_id="your-instance-id"
command="your-command"

# Run command using SSM
aws ssm send-command \
  --instance-ids "$instance_id" \
  --document-name "AWS-RunShellScript" \
  --parameters commands="$command"

echo "Command sent to the EC2 instance via SSM."
