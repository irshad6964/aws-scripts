#!/bin/bash

# Set your AWS region, old instance details, and new instance details
AWS_REGION="your_aws_region"
OLD_AMI_ID="your_old_ami_id"
OLD_INSTANCE_ID="your_old_instance_id"
NEW_AMI_ID="your_new_ami_id"
NEW_INSTANCE_ID="your_new_instance_id"

# Get the list of CloudWatch alarm names for the old instance
alarm_names=$(aws cloudwatch describe-alarms \
  --region "$AWS_REGION" \
  --query "MetricAlarms[?Dimensions[?Name=='InstanceId'&&Value=='$OLD_INSTANCE_ID']&&Dimensions[?Name=='ImageId'&&Value=='$OLD_AMI_ID']].AlarmName" \
  --output text)

# Update each alarm with the new instance details
for alarm_name in $alarm_names; do
  aws cloudwatch put-metric-alarm \
    --region "$AWS_REGION" \
    --alarm-name "$alarm_name" \
    --actions-enabled \
    --alarm-description "Updated alarm for $NEW_INSTANCE_ID with AMI $NEW_AMI_ID" \
    --dimensions Name=InstanceId,Value="$NEW_INSTANCE_ID" Name=ImageId,Value="$NEW_AMI_ID"
done
