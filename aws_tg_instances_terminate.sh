#!/bin/bash

# Set your AWS credentials
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
export AWS_DEFAULT_REGION="us-east-1"

# Set the name of your target group
TARGET_GROUP_NAME="YOUR_TARGET_GROUP_NAME"

# Get the list of instance IDs in the target group
INSTANCE_IDS=$(aws elbv2 describe-target-health --target-group-name $TARGET_GROUP_NAME --query 'TargetHealthDescriptions[].Target.Id' --output text)

# Loop through the instance IDs and terminate them one by one
for INSTANCE_ID in $INSTANCE_IDS; do
    echo "Terminating instance: $INSTANCE_ID"

    # Terminate the instance
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID

    # Wait until the terminated instance is no longer part of the target group
    while true; do
        TARGET_HEALTH=$(aws elbv2 describe-target-health --target-group-name $TARGET_GROUP_NAME --query 'TargetHealthDescriptions[?Target.Id==`'$INSTANCE_ID'`].TargetHealth.State' --output text)
        if [ -z "$TARGET_HEALTH" ]; then
            echo "Instance removed from target group: $INSTANCE_ID"
            break
        fi
        echo "Waiting for instance to be removed from target group: $INSTANCE_ID"
        sleep 10
    done

    # Wait until a new instance is registered and becomes healthy in the target group
    while true; do
        NEW_INSTANCE_ID=$(aws elbv2 describe-target-health --target-group-name $TARGET_GROUP_NAME --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`].Target.Id' --output text)
        if [ ! -z "$NEW_INSTANCE_ID" ]; then
            echo "New instance registered: $NEW_INSTANCE_ID"
            break
        fi
        echo "Waiting for new instance to be registered in the target group..."
        sleep 10
    done

    # Wait until the new instance becomes healthy
    while true; do
        NEW_INSTANCE_HEALTH=$(aws elbv2 describe-target-health --target-group-name $TARGET_GROUP_NAME --targets Id=$NEW_INSTANCE_ID --query 'TargetHealthDescriptions[].TargetHealth.State' --output text)
        if [ "$NEW_INSTANCE_HEALTH" == "healthy" ]; then
            echo "New instance is healthy: $NEW_INSTANCE_ID"
            break
        fi
        echo "Waiting for new instance to become healthy: $NEW_INSTANCE_ID"
        sleep 10
    done
done

echo "All instances in the target group have been terminated."
