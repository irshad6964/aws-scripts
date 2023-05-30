#!/bin/bash

# TG Healthcheck Script

# Set your AWS credentials
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
export AWS_DEFAULT_REGION="us-east-1"

# Set the name of your target group
TARGET_GROUP_NAME="YOUR_TARGET_GROUP_NAME"

# Get the list of registered targets in the target group
REGISTERED_TARGETS=$(aws elbv2 describe-target-health --target-group-name $TARGET_GROUP_NAME --query 'TargetHealthDescriptions[].{ID:Target.Id, Health:TargetHealth.State}' --output text)

# Variable to track if any target is unhealthy
UNHEALTHY_TARGETS=false

# Loop through the registered targets and display their health status
echo "Health status of targets in the target group:"
echo "-------------------------------------------"
echo "$REGISTERED_TARGETS" | while read -r TARGET; do
    TARGET_ID=$(echo "$TARGET" | awk '{print $1}')
    TARGET_HEALTH=$(echo "$TARGET" | awk '{print $2}')

    echo "Target ID: $TARGET_ID"
    echo "Health: $TARGET_HEALTH"
    echo "-------------------------------------------"

    # Check if the target is unhealthy
    if [ "$TARGET_HEALTH" != "healthy" ]; then
        UNHEALTHY_TARGETS=true
    fi
done

# Check if any targets are unhealthy and report success or failure
if [ "$UNHEALTHY_TARGETS" = true ]; then
    echo "Some targets in the target group are unhealthy. Task failed."
    exit 1
else
    echo "All targets in the target group are healthy. Task succeeded."
    exit 0
fi
