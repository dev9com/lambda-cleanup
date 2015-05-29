#!/bin/bash
export EC2_URL=https://$AWS_REGION.ec2.amazonaws.com
export AWS_AUTO_SCALING_URL=https://autoscaling.$AWS_REGION.amazonaws.com

export LAUNCH_CONFIG=cost-watch-launch-config
export AUTO_SCALE_GROUP=cost-watch-auto-scale-group

echo "Deleting cost-watch-stop scheduler"
aws autoscaling delete-scheduled-action --scheduled-action-name "cost-watch-stop" \
  --auto-scaling-group-name "$AUTO_SCALE_GROUP"

echo "Deleting cost-watch-start scheduler"
aws autoscaling delete-scheduled-action --scheduled-action-name "cost-watch-start" \
  --auto-scaling-group-name "$AUTO_SCALE_GROUP"

echo "Stopping $AUTO_SCALE_GROUP auto scaling group instances"
aws autoscaling update-auto-scaling-group --auto-scaling-group-name "$AUTO_SCALE_GROUP" \
  --min-size 0  --max-size 0

sleep 30

echo "Deleting $AUTO_SCALE_GROUP auto scaling group"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name "$AUTO_SCALE_GROUP"

echo "Deleting $AUTO_SCALE_GROUP launch configuration"
aws autoscaling delete-launch-configuration --launch-configuration-name "$LAUNCH_CONFIG"
