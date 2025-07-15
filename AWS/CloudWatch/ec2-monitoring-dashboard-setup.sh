#!/bin/bash

#Modified Script :-

#create vpc
vpcId=$(aws ec2 create-vpc --cidr-block 10.0.1.0/16 --query 'Vpc.VpcId' --output text)
echo "VPC ID is:- $vpcId"

#create 2 subnets inside vpc
echo "Creating 2 subnets (public/private)"

publicSubnetId=$(aws ec2 create-subnet \
  --vpc-id "$vpcId" \
  --cidr-block 10.0.0.0/24 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet}]' \
  --query 'Subnet.SubnetId' --output text)

echo "Public subnet id is: $publicSubnetId"

privateSubnetId=$(aws ec2 create-subnet \
  --vpc-id "$vpcId" \
  --cidr-block 10.0.2.0/24 \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet}]' \
  --query 'Subnet.SubnetId' --output text)

echo "Private subnet id is: $privateSubnetId"

# create an Internet gateway

echo "Creating internet gateway"

internetGatewayId=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=internet-gateway}]' \
    --query 'InternetGateway.InternetGatewayId' --output text
)

echo "Internet Gateway Id is:- $internetGatewayId"

#Attaching IGW to VPC

echo "Attach internet-gateway to vpc id: $vpcId"
aws ec2 attach-internet-gateway \
         --internet-gateway-id "$internetGatewayId" \
         --vpc-id "$vpcId"

echo "IG added to VPC"

#creating routing table

echo "Creating routing table"

routeTableId=$(aws ec2 create-route-table --vpc-id "$vpcId" --query 'RouteTable.RouteTableId' --output text)

echo "Route table created with id: $routeTableId"

#Attach route table with public subnet

echo "Attaching route-table with public subnet"

associationId=$(aws ec2 associate-route-table --route-table-id "$routeTableId" --subnet-id "$publicSubnetId" --query 'AssociationId' --output text)

echo "Attached successfully with AssociationId: $associationId"

#opened a route in the routing table to the destination 0.0.0.0/0 
#and attached it to I.G. 
aws ec2 create-route \
  --route-table-id "$routeTableId" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "$internetGatewayId"

echo "Attaching to I.G. done"
#--------------------------------------------Launching EC2 instance inside the public subnet and verify using ssh------------------------------------------
REGION="${REGION:-$(aws configure get region)}"
KEY_NAME="ubuntu-key"
KEY_FILE="$KEY_NAME.pem"
SECURITY_GROUP_NAME="ubuntu-sg"
INSTANCE_TYPE="t3.micro"

# Create a security group
echo "Creating security group: $SECURITY_GROUP_NAME"

securityGroupId=$(aws ec2 create-security-group \
  --group-name "$SECURITY_GROUP_NAME" \
  --description "Allow SSH" \
  --vpc-id "$vpcId" \
  --query 'GroupId' --output text)

echo "Security Group ID: $securityGroupId"

aws ec2 authorize-security-group-ingress \
  --group-id "$securityGroupId" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

echo "Creating key pair: $KEY_NAME\n"
aws ec2 create-key-pair --region "$REGION" --key-name "$KEY_NAME" --query 'KeyMaterial' --output text > "$KEY_FILE"
echo $KEY_FILE
chmod 400 "$KEY_FILE"
echo "Key saved to $KEY_FILE"

echo "Fetching latest Ubuntu 22.04 LTS AMI ID..."
AMI_ID=$(aws ec2 describe-images \
  --region "$REGION" \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    "Name=architecture,Values=x86_64" \
    "Name=virtualization-type,Values=hvm" \
    "Name=root-device-type,Values=ebs" \
  --query 'Images[*].[ImageId,CreationDate]' \
  --output text | \
  sort -k2 -r | \
  head -n 1 | \
  awk '{print $1}')

echo "Latest AMI ID found: $AMI_ID"

# Launch an EC2 instance
echo "Launching EC2 instance..."

instanceId=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$securityGroupId" \
  --subnet-id "$publicSubnetId" \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyPublicInstance}]' \
  --query 'Instances[0].InstanceId' --output text)

echo "Launched instance with ID: $instanceId"


# Get public IP of instance
echo "Waiting for instance to be in 'running' state..."
aws ec2 wait instance-running --instance-ids "$instanceId"

publicIp=$(aws ec2 describe-instances \
  --instance-ids "$instanceId" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "EC2 instance is running with Public IP: $publicIp"


# ----------------------------------------------------------------Create SNS Topic & Subscription---------------------------------------------------------

snsTopicName="CPU-ALARM_TOPIC"
snsEmail="sahoopiyush29@gmail.com"

echo "Creating SNS Topic: $snsTopicName"

snsTopicArn=$(aws sns create-topic \
    --name "$snsTopicName" \
    --query 'TopicArn' \
    --output text)

echo "SNS Topic ARN: $snsTopicArn"

echo "Subscribing $snsEmail to SNS topic"

aws sns subscribe \
    --topic-arn "$snsTopicArn" \
    --protocol email \
    --notification-endpoint "$snsEmail"

echo "Please check mail and validate the notification"
echo "Press Enter to continue after confirming the subscription..."
read

# ------------------------------------------------------------------------CreateCloudWatchAlarm------------------------------------------------------------

alarmName="HighCPUUtilizationAlarm"

#Alarm 1: High CPU-Utilization
aws cloudwatch put-metric-alarm \
  --alarm-name "$alarmName" \
  --alarm-description "Alarm when CPU exceeds 70%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --dimensions "Name=InstanceId,Value=$instanceId" \
  --evaluation-periods 2 \
  --alarm-actions "$snsTopicArn" \
  --unit Percent

echo "Alarm Added to EC2 instance with instanceId: $INSTANCE_ID"

#--------------------------------------------------------------------creating more alarms------------------------------------------------------------------


# Alarm 2: Status Check Failed
aws cloudwatch put-metric-alarm \
  --alarm-name "StatusCheckFailed-$instanceId" \
  --metric-name StatusCheckFailed \
  --namespace AWS/EC2 \
  --statistic Maximum \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --dimensions "Name=InstanceId,Value=$instanceId" \
  --evaluation-periods 1 \
  --alarm-actions "$snsTopicArn"

# Alarm 3: Low CPU usage (< 10%)
aws cloudwatch put-metric-alarm \
  --alarm-name "LowCPUUtilization-$instanceId" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 10 \
  --comparison-operator LessThanThreshold \
  --dimensions "Name=InstanceId,Value=$instanceId" \
  --evaluation-periods 2 \
  --alarm-actions "$snsTopicArn" \
  --unit Percent

# Alarm 4: NetworkPacketsIn spike
aws cloudwatch put-metric-alarm \
  --alarm-name "HighNetworkPacketsIn-$instanceId" \
  --metric-name NetworkPacketsIn \
  --namespace AWS/EC2 \
  --statistic Sum \
  --period 300 \
  --threshold 5000 \
  --comparison-operator GreaterThanThreshold \
  --dimensions "Name=InstanceId,Value=$instanceId" \
  --evaluation-periods 1 \
  --alarm-actions "$snsTopicArn" \
  --unit Count

# Alarm 5: DiskReadBytes > 1 GB
aws cloudwatch put-metric-alarm \
  --alarm-name "HighDiskRead-$instanceId" \
  --metric-name DiskReadBytes \
  --namespace AWS/EC2 \
  --statistic Sum \
  --period 300 \
  --threshold 1000000000 \
  --comparison-operator GreaterThanThreshold \
  --dimensions "Name=InstanceId,Value=$instanceId" \
  --evaluation-periods 1 \
  --alarm-actions "$snsTopicArn" \
  --unit Bytes

#------------------------------------------------------------------Create CloudWatch Dashboard-------------------------------------------------------------

dashboardName="EC2MonitoringDashboard"
aws cloudwatch put-dashboard \
  --dashboard-name "$dashboardName" \
  --dashboard-body "{
    \"widgets\": [
      {
        \"type\": \"metric\",
        \"x\": 0,
        \"y\": 0,
        \"width\": 12,
        \"height\": 6,
        \"properties\": {
          \"metrics\": [[\"AWS/EC2\", \"CPUUtilization\", \"InstanceId\", \"$instanceId\"]],
          \"title\": \"CPU Utilization\",
          \"stat\": \"Average\",
          \"period\": 300
        }
      },
      {
        \"type\": \"metric\",
        \"x\": 12,
        \"y\": 0,
        \"width\": 12,
        \"height\": 6,
        \"properties\": {
          \"metrics\": [[\"AWS/EC2\", \"StatusCheckFailed\", \"InstanceId\", \"$instanceId\"]],
          \"title\": \"Status Check Failures\",
          \"stat\": \"Maximum\",
          \"period\": 60
        }
      },
      {
        \"type\": \"metric\",
        \"x\": 0,
        \"y\": 6,
        \"width\": 12,
        \"height\": 6,
        \"properties\": {
          \"metrics\": [[\"AWS/EC2\", \"NetworkPacketsIn\", \"InstanceId\", \"$instanceId\"]],
          \"title\": \"Network Packets In\",
          \"stat\": \"Sum\",
          \"period\": 300
        }
      },
      {
        \"type\": \"metric\",
        \"x\": 12,
        \"y\": 6,
        \"width\": 12,
        \"height\": 6,
        \"properties\": {
          \"metrics\": [[\"AWS/EC2\", \"DiskReadBytes\", \"InstanceId\", \"$instanceId\"]],
          \"title\": \"Disk Read Bytes\",
          \"stat\": \"Sum\",
          \"period\": 300
        }
      },
      {
        \"type\": \"metric\",
        \"x\": 0,
        \"y\": 12,
        \"width\": 24,
        \"height\": 6,
        \"properties\": {
          \"metrics\": [[\"AWS/EC2\", \"CPUUtilization\", \"InstanceId\", \"$instanceId\"]],
          \"title\": \"Low CPU Utilization Check (< 10%)\",
          \"stat\": \"Average\",
          \"period\": 300
        }
      }
    ]
  }"

echo "CloudWatch dashboard '$dashboardName' created with EC2 instance"
