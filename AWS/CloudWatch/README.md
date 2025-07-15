# EC2 Monitoring Dashboard Setup (Advanced VPC + CloudWatch + SNS + Alarms)

This project automates the deployment of a **VPC-based infrastructure** on AWS, provisions a **public EC2 instance**, and sets up **CloudWatch alarms and a monitoring dashboard** using AWS CLI and Bash.

---

## 🔧 What This Script Does

- 🛠 **Creates a custom VPC** with:
  - 1 Public Subnet
  - 1 Private Subnet
  - Internet Gateway (IGW)
  - Routing table for internet access
- 🔐 **Configures networking and security**:
  - Security Group with SSH access
  - Key Pair for EC2 SSH login
- 🖥 **Launches an EC2 instance** in the public subnet
- 🔔 **Sets up an SNS topic** and email subscription for notifications
- 📈 **Creates 5 CloudWatch Alarms**:
  - High CPU Usage (> 70%)
  - Low CPU Usage (< 10%)
  - Status Check Failure
  - High Network Packets In
  - High Disk Read
- 📊 **Creates a CloudWatch Dashboard** to monitor EC2 health

---

## 🚀 Prerequisites

- ✅ AWS CLI configured (`aws configure`)
- ✅ IAM User with permissions:
  - `ec2:*`
  - `cloudwatch:*`
  - `sns:*`
  - `iam:CreateServiceLinkedRole`
- ✅ Linux terminal or WSL
- ✅ Verified email address for SNS

---

## 🔍 Step-by-Step Overview

### 1. **Networking Setup**
- VPC CIDR: `10.0.1.0/16`
- Subnets:
  - Public: `10.0.0.0/24`
  - Private: `10.0.2.0/24`
- Internet Gateway + Route table created and attached to public subnet.

### 2. **Security & Access**
- Creates a security group with port 22 open.
- Creates and saves an EC2 key pair locally (`ubuntu-key.pem`).

### 3. **EC2 Launch**
- Uses the latest **Ubuntu 22.04 LTS** AMI.
- Launches a `t3.micro` instance into the public subnet.
- Associates a public IP for SSH access.

### 4. **CloudWatch Alarms (Monitoring + Alerting)**
#### Alarm Conditions:
| Alarm Name                   | Metric              | Threshold         | Action                         |
|-----------------------------|---------------------|-------------------|--------------------------------|
| HighCPUUtilizationAlarm     | CPUUtilization      | > 70%             | Send SNS Email                 |
| LowCPUUtilization           | CPUUtilization      | < 10%             | Send SNS Email                 |
| StatusCheckFailed           | StatusCheckFailed   | >= 1              | Send SNS Email                 |
| HighNetworkPacketsIn        | NetworkPacketsIn    | > 5000 (Sum)      | Send SNS Email                 |
| HighDiskRead                | DiskReadBytes       | > 1 GB (Sum)      | Send SNS Email                 |

### 5. **Dashboard Setup**
Creates a **CloudWatch dashboard** `EC2MonitoringDashboard` with widgets for:
- CPU Utilization
- Status Check Failures
- Network Packets
- Disk Read Bytes
- Low CPU (<10%)

---

## 📧 Email Alerts

1. An **SNS topic** (`CPU-ALARM_TOPIC`) is created.
2. The email provided (`sahoopiyush29@gmail.com`) must be verified before alerts will be delivered.
3. After running the script, **check your email and click "Confirm Subscription"**.

---

## 💻 How to Run

```bash
chmod +x setup.sh
./setup.sh
