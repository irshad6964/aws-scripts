#!/bin/bash

# This script will directly terminates the instances without deregistering them
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

    # Wait until the terminated instance becomes healthy
    while true; do
        INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].State.Name' --output text)
        if [ "$INSTANCE_STATE" == "terminated" ]; then
            echo "Instance terminated: $INSTANCE_ID"
            break
        fi
        echo "Waiting for instance to become healthy: $INSTANCE_ID"
        sleep 10
    done
done

echo "All instances in the target group have been terminated."
