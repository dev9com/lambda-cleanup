#!/bin/bash
export AWS_AUTO_SCALING_HOME=/usr/local/Cellar/auto-scaling/1.0.61.6/libexec/
export AMI_ID=ami-dfc39aef
export AWS_REGION=us-west-2
export ZONE=${AWS_REGION}a
export EC2_URL=https://$AWS_REGION.ec2.amazonaws.com
export AWS_AUTO_SCALING_URL=https://autoscaling.$AWS_REGION.amazonaws.com

export LAUNCH_CONFIG=cost-watch-launch-config
export AUTO_SCALE_GROUP=cost-watch-auto-scale-group
export KEY_NAME=cost-watch

aws autoscaling create-launch-configuration --key-name $KEY_NAME --instance-type t2.micro   \
  --user-data file://lambda-call.sh --image-id $AMI_ID   \
  --launch-config "$LAUNCH_CONFIG" --iam-instance-profile ec2_lambda_exec

aws autoscaling create-auto-scaling-group --auto-scaling-group-name "$AUTO_SCALE_GROUP" \
   --launch-configuration-name "$LAUNCH_CONFIG"   --availability-zones "$ZONE"  \
   --min-size 0   --max-size 0

aws autoscaling suspend-processes --auto-scaling-group-name "$AUTO_SCALE_GROUP" \
   --scaling-processes ReplaceUnhealthy

# # UTC: 1:00, 7:00, 13:00, 19:00
aws autoscaling put-scheduled-update-group-action --scheduled-action-name "cost-watch-start" \
  --auto-scaling-group-name "$AUTO_SCALE_GROUP" --min-size 1   --max-size 1 \
  --recurrence "0 */4 * * *"

# # UTC: 1:55, 7:55, 13:55, 19:55
aws autoscaling put-scheduled-update-group-action --scheduled-action-name "cost-watch-stop" \
  --auto-scaling-group-name "$AUTO_SCALE_GROUP" --min-size 0   --max-size 0 \
  --recurrence "30 */4 * * *"
