# AWS Project: Blog Page Application

## Project Description

The **Blog Page Application** project aims to deploy a blog application as a web application using the Django Framework on AWS Cloud Infrastructure. The infrastructure includes:

- **Application Load Balancer (ALB)** with an **Auto Scaling Group** of **Elastic Compute Cloud (EC2)** Instances.
- **Relational Database Service (RDS)** on a defined **VPC**.
- **CloudFront** and **Route 53** services to manage secure traffic.
- **S3 Bucket** for storing pictures and videos uploaded by the user on their blog page.

## Steps to Solution

### Step 1: Create Dedicated VPC and Components

#### 1.1 VPC

- **Create VPC:**
  - Name: `awsproject-VPC`
  - CIDR Block: `10.10.0.0/16`
  - No IPv6 CIDR block
  - Tenancy: Default

- **Enable DNS Hostnames:**
  - Select `awsproject-VPC`, click **Actions** → **Edit VPC settings** → Enable **DNS hostnames**.

#### 1.2 Subnets

- **Create Public Subnets:**
  - `awsproject-public-subnet-1A`: AZ `us-east-1a`, CIDR Block `10.10.10.0/24`
  - `awsproject-public-subnet-1B`: AZ `us-east-1b`, CIDR Block `10.10.20.0/24`

- **Create Private Subnets:**
  - `awsproject-private-subnet-1A`: AZ `us-east-1a`, CIDR Block `10.10.11.0/24`
  - `awsproject-private-subnet-1B`: AZ `us-east-1b`, CIDR Block `10.10.21.0/24`

- **Enable Auto-Assign IP for Public Subnets:**
  - Select each public subnet, click **Actions** → **Edit subnet settings** → Enable **Auto-assign public IPv4 address**.

#### 1.3 Internet Gateway

- **Create Internet Gateway:**
  - Name: `awsproject-IGW`
  
- **Attach Internet Gateway:**
  - Attach `awsproject-IGW` to `awsproject-VPC`.

#### 1.4 Route Table

- **Rename Main Route Table:**
  - Rename the main route table as `awsproject-public-RT`.

- **Create Private Route Table:**
  - Name: `awsproject-private-RT`

- **Add Route to Public Route Table:**
  - Destination: `0.0.0.0/0`
  - Target: `awsproject-IGW`

- **Subnet Association:**
  - Associate private subnets with `awsproject-private-RT`.
  - Associate public subnets with `awsproject-public-RT`.

#### 1.5 Endpoint

- **Create Endpoint:**
  - Name Tag: `awsproject-endpoint`
  - Service Name: `com.amazonaws.us-east-1.s3` (Type: Gateway)
  - VPC: `awsproject-VPC`
  - Route Table: `Private route tables`
  - Policy: `Full Access`

### Step 2: Create Security Groups (ALB → EC2 → RDS)

#### 2.1 ALB Security Group

- **Name:** `awsproject_ALB_Sec_Group`
- **Description:** Allows traffic on HTTP and HTTPS ports from anywhere.
- **VPC:** `awsproject-VPC`

- **Inbound Rules:**
  - HTTP (80) → Anywhere
  - HTTPS (443) → Anywhere

#### 2.2 EC2 Security Group

- **Name:** `awsproject_EC2_Sec_Group`
- **Description:** Allows traffic from `awsproject_ALB_Sec_Group` on HTTP and HTTPS ports, and SSH from anywhere.
- **VPC:** `awsproject-VPC`

- **Inbound Rules:**
  - HTTP (80) → `awsproject_ALB_Sec_Group`
  - HTTPS (443) → `awsproject_ALB_Sec_Group`
  - SSH (22) → Anywhere (10.10.0.0/16 VPC CIDR)

#### 2.3 RDS Security Group

- **Name:** `awsproject_RDS_Sec_Group`
- **Description:** Allows traffic from `awsproject_EC2_Sec_Group` on MYSQL/Aurora port.
- **VPC:** `awsproject-VPC`

- **Inbound Rules:**
  - MYSQL/Aurora (3306) → `awsproject_EC2_Sec_Group`

#### 2.4 NAT Instance Security Group

- **Name:** `awsproject_NAT_Sec_Group`
- **Description:** NAT instance security group.
- **VPC:** `awsproject-VPC`

- **Inbound Rules:**
  - All Traffic → 10.10.0.0/16 (VPC CIDR Block)
  - SSH (22) → Anywhere

### Step 3: Create RDS

#### 3.1 Create RDS Subnet Group

- Navigate to the **RDS console** and select **Subnet Groups** from the left-hand menu.
- Click **Create DB Subnet Group**.

```text
Name               : `awsproject_RDS_Subnet_Group`
Description        : `awsproject RDS Subnet Group`
VPC                : `awsproject-VPC`
Availability Zones : Select 2 AZs in awsproject_VPC
Subnets            : Select 2 Private Subnets in these AZs
```

#### 3.2 Create the RDS Database

- In the **RDS console**, click the **Create database** button.

- **Database Creation Method:**
  - Choose: **Standard Create**

- **Engine Options:**
  - Engine: **MySQL**
  - Version: **8.0.35**

- **Templates:**
  - Select: **Free Tier**

- **Settings:**
  - **DB Instance Identifier:** `awsproject-RDS`
  - **Master Username:** `admin`
  - **Password:** `Tech12345`

- **DB Instance Class:**
  - Choose: **Burstable classes (includes t classes)** → `db.t3.micro`

- **Storage:**
  - Allocate: **20 GB**
  - Enable **Autoscaling** (up to 40 GB)

- **Connectivity:**
  - **VPC:** `awsproject-VPC`
  - **Subnet Group:** `awsproject_RDS_Subnet_Group`
  - **Public Access:** No
  - **VPC Security Groups:** Select existing → `awsproject_RDS_Sec_Group`
  - **Availability Zone:** No preference
  - **Database Port:** `3306`

- **Database Authentication:**
  - Choose: **Password authentication**

- **Additional Configuration:**
  - **Initial Database Name:** `blogpage`
  - **Backup:** Uncheck **Enable automatic backups**
  - **Maintenance Window:** Uncheck
  - **Deletion Protection:** Uncheck

- Click **Create Database**.

### Step 4: Create Two S3 Buckets and Configure One as a Static Website

#### 4.1 Blog Website's S3 Bucket

- Go to the **S3 Console** and click **Create Bucket**.

##### Bucket Configuration:

- **Bucket Name:** `awsproject<name>blog`
- **Region:** N.Virginia

##### Object Ownership:

- **ACLs Enabled:**
  - **Bucket Owner Preferred**

##### Block Public Access Settings:

- **Block All Public Access:** Unchecked

- **Other Settings:** Keep them as they are

- Click **Create Bucket**.

#### 4.2 S3 Bucket for Failover Scenario

- Go to the **S3 Console** and click **Create Bucket**.

```text
Bucket Name           : www.<YOUR DNS NAME>
Region                : N.Virginia
Block All Public Access : Unchecked
Object Ownership      : ACLs enabled
Other Settings        : Keep them as they are
```

- Click **Create Bucket**.

- Select the created `www.<YOUR DNS NAME>` bucket → **Properties** → **Static website hosting**.

```text
Static Website Hosting : Enable
Hosting Type           : Host a static website
Index Document         : index.html
```
- Save changes.

- Select the `www.<YOUR DNS NAME>` bucket → click **Upload** and upload `index.html` and `sorry.jpg` files from the given folder → **Permissions** → Grant **Grant public-read access** → Check the warning message.

### Step 5: Copy Files from `awsproject` Repository

- Download or clone the `awsproject` repository from GitHub.
- Copy the necessary files to your local environment.

### Step 6: Prepare Your GitHub Repository

- Create a **private project repository** on your GitHub account.
- Clone it to your local environment.
- Copy all files and folders downloaded from the `awsproject` repository into this folder.
- Commit and push them to your private GitHub repository.

### Step 7: Prepare a Userdata Script for the Launch Template

Create the following **userdata script** to be utilized in the Launch Template:

```bash
#!/bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
git clone https://github.com/xxxxxxxxxxxxx/xxxxxxxxxxxxxxx.git
cd /home/ubuntu/xxxxxxxxxxxxxx/BlogDjango
apt install python3-pip -y
apt-get install python3.8-dev default-libmysqlclient-dev -y
apt-get install libjpeg-dev zlib1g-dev -y -qq
pip3 install -r requirements.txt
cd /home/ubuntu/xxxxxxxxxxxxxxxxx/BlogDjango/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80
```

### Step 8: Configure and Deploy Your Application

- **Write RDS Database Endpoint and S3 Bucket Name** in the settings file provided by the AWS Fullstack Developer team.
- Update the following variables in the `/src/cblog/settings.py` file:

```text
- AWS_STORAGE_BUCKET_NAME: Set this to the name of your S3 bucket (e.g., awsproject_S3_<name>_Blog).
- AWS_S3_REGION_NAME: Set this to the region of your S3 bucket.
- Database configuration:
  a. NAME: Set this to the database name.
  b. HOST: Set this to the RDS database endpoint.
  c. PORT: Set this to the RDS port.
- PASSWORD: Store this in the `/src/.env` file to keep it secure and not exposed in the settings file.
```

- **Push your application** to your public GitHub repository.

### Final Check

- Ensure the **userdata script** is working correctly by creating a new instance in the public subnet and demonstrating its functionality to students.

### Step 9: Create NAT Instance in Public Subnet

To launch a NAT instance, follow these steps:

1. Go to the **EC2 console** and click the **Launch instance** button.
2. Filter by typing "ami-037eb9e678c1a8ed9" in the search box.
3. Select the NAT Instance.
4. Configure the instance details:

```text
Instance Type               : t2.micro
Network                     : awsproject-VPC
Subnet                      : awsproject-public-subnet-1A (Choose one of your Public Subnets)
Other Features              : Keep them as they are
Storage                     : Keep it as is
Tags: 
    - Key: Name 
    - Value: AWS project NAT Instance
```

5. Configure Security Group:

```text
- Select an existing security group: awsproject_NAT_Sec_Group
```

6. Review and select your PEM key.

!!!IMPORTANT!!!
- After the NAT instance is created, select the instance and enable **Actions-->> Networking -->> Change Source/Destination Check**. `Source / destination checking-->> stop`

- Go to the private route table and add a route:

```text
Destination : 0.0.0.0/0
Target      : Instance ---> Select NAT Instance
Save
```

### Step 10: Create Launch Template and IAM Role for It

#### 10.1 Create IAM Role

1. Go to the **IAM console** and click **Roles** on the right-hand menu, then click **Create Role**.
   
```text
Trusted Entity  : EC2 
Policy          : AmazonS3FullAccess
Tags            : No tags
Role Name       : awsproject_EC2_S3_Full_Access
Description     : For EC2, S3 Full Access Role
```

#### 10.2 Create Launch Template

1. Go to the **EC2 console** and select **Launch Templates** from the left-hand menu.
2. Click the **Create Launch Template** button.

```text
Launch Template Name             : awsproject_launch_template
Template Version Description     : Blog Web Page version 1
Amazon Machine Image (AMI)       : Ubuntu 22.04
Instance Type                    : t2.micro
Key Pair                         : xxxxx.pem
Network Platform                 : VPC
Security Groups                  : awsproject_EC2_sec_group
Storage (Volumes)                : Keep it as is
Resource Tags                    : 
    - Key: Name   
    - Value: awsproject_web_server
Advanced Details:
    - IAM Instance Profile        : awsproject_EC2_S3_Full_Access
    - Termination Protection      : Enable
    - User Data:
#!/bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
git clone https://github.com/xxxxxxxxxxx/xxxxxxxxx.git
cd /home/ubuntu/xxxxxxxxxx/BlogDjango
apt install python3-pip -y
apt-get install python3.8-dev default-libmysqlclient-dev -y
apt-get install libjpeg-dev zlib1g-dev -y -qq
pip3 install -r requirements.txt
cd /home/ubuntu/xxxxxxxxxxxxx/BlogDjango/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80
```

3. Create the launch template.

### Step 11: Create Certification for Secure Connection

1. Go to the **Certification Manager Console** and click **Request a Certificate**.
2. Select **Request a public certificate**, then click **Request a Certificate**.

```text
Domain Name        : *.<YOUR DNS NAME>
Validation Method  : DNS validation
Tags               : No tags
```

3. Review the settings, click **Confirm and Request**, and wait for activation.

### Step 12: Create ALB and Target Group

1. Go to the **Load Balancer** section in the EC2 console.
2. Click **Create Load Balancer** and select **Application Load Balancer**.

#### Basic Configuration
```text
Name                    : awsproject-ALB
Scheme                  : internet-facing
Load balancer IP address type: IPv4
```
#### Network Mapping
```
VPC                     : awsproject-VPC
Availability Zones      : 
    - Subnets           : 
        1. awsproject-public-subnet-1A
        2. awsproject-public-subnet-1B
```
#### Configure Security Groups

```text
Security Groups         : awsproject_ALB_Sec_group
```
#### Listeners and routing

```text
Listeners               : 
                        :HTTP,
                        :HTTPS
```

#### Target Group

```text
Target Type             : Instance
Name                    : awsprojectTargetGroup
Protocol                : HTTP
IP adress type:         : IPv4
VPC                     : awsproject-VPC
Port                    : 80
Protocol Version        : HTTP1
Health Check:
    - Protocol          : HTTP
    - Path              : /
  Advanced healty checks
    - Port              : Traffic port
    - Healthy Threshold : 3
    - Unhealthy Threshold : 2
    - Timeout           : 5
    - Interval          : 20
    - Success Code      : 200
```

#### Register Targets

- Without registering any targets, click **Next: Review** and then **Create**.


#### Secure Listener Settings

```text
Certificate Type        : Choose a certificate from ACM (recommended)
Certificate Name        : "*.aws.us" certificate
Security Policy         : Keep it as is
click "create load balancer" button
```

#### Redirect HTTP to HTTPS

1. Go to the ALB console and select the **Listeners** sub-section.
2. Select the HTTP: 80 rule and click **Manage listener/Edit Listener**.

```text
Default Action(s)       :
  Routing actions       : Redirect to URL
        - URI parts
        - Protocol HTTPS         Port:443
        - 301 - Permanently Moved
```

- Check the ALB DNS to ensure it is working, though it may display a "not secure" message until Route 53 is configured.

### Step 13: Create Auto Scaling Group with Launch Template

1. Go to the **Auto Scaling Group** section on the left-hand menu and click **Create Auto Scaling Group**.

#### Choose Launch Template

```text
Auto Scaling Group Name           : awsproject_ASG
Launch Template                   : awsproject_launch_template
```

#### Configure Settings

```text
Instance Purchase Options         : Adhere to launch template
Network                           :
    - VPC                         : awsproject-VPC
    - Subnets                     : Private 1A and Private 1B
```

#### Configure Advanced Options

```text
Load Balancing                    : Attach to an existing load balancer
Choose Target Groups              : awsprojectTargetGroup
Health Checks
    - Health Check Type           : ELB
    - Health Check Grace Period   : 300
```

#### Configure Group Size and Scaling Policies

```text
Group Size:
    - Desired Capacity            : 2
    - Minimum Capacity            : 2
    - Maximum Capacity            : 4
Scaling Policies:
    - Target Tracking Scaling Policy:
        - Scaling Policy Name     : Target Tracking Policy
        - Metric Type             : Average CPU Utilization
        - Target Value            : 70
```

#### Add Notifications

```text
Notification:
    - Name                        : Notification1
    - Send to                     : awsproject-SNS
    - Recipients                  : mail address
    - Event Type                  : Select all 
```

### Step 14: Create Cloudfront in front of ALB

Go to the Cloudfront menu and click start.

#### Origin Settings

```text
Origin Domain Name          : Choose your ALB
Protocol                    : Match Viewer
HTTP Port                   : 80
HTTPS                       : 443
Minimum Origin SSL Protocol : Keep it as is
Origin Path                 : Leave empty (this means, define for root '/')
Name                        : Keep it as is
Add custom header           : No header
Enable Origin Shield        : No
Additional settings         : Keep it as is
```

#### Default Cache Behavior

```text
Path pattern                                : Default (*)
Compress objects automatically              : Yes
Viewer Protocol Policy                      : Redirect HTTP to HTTPS
Allowed HTTP Methods                        : GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
Cached HTTP Methods                         : Select OPTIONS

Cache key and origin requests
- Use legacy cache settings
  Headers     : Include the following headers
    Add Header
    - Accept
    - Accept-Charset
    - Accept-Datetime
    - Accept-Encoding
    - Accept-Language
    - Authorization
    - Cloudfront-Forwarded-Proto
    - Host
    - Origin
    - Referrer
Cookies                                 : All
Query Strings                           : All
Other stuff                             : Keep them as are 
```

- WAF: Do not enable security protections

#### Settings

```text
Price Class                             : Use all edge locations (best performance)
Alternate Domain Names                  : www.<domain.name>.com
SSL Certificate                         : Custom SSL Certificate (example.com) ---> Select your certificate created before
Other stuff                             : Keep them as are                  
```
- Click Create Record.

### Step 15: Create Route 53 with Failover settings

Go to the Route53 console and select Health checks on the left-hand menu. Click create health check.

#### Configure Health Check

```text
Name                : aws-project-health-check
What to monitor     : Endpoint
Specify endpoint by : Domain Name
Protocol            : HTTP
Domain Name         : Write cloudfront domain name
Other stuff         : Keep them as are
```

- Click Hosted zones on the left-hand menu.
- Click your Hosted zone: `<YOUR DNS NAME>`.
- Click Create Record.

```text
record 1
Record name             : www
Record Type             : A - Routes traffic to an IPv4 address and some AWS resources
Alias                   : ok
     Route traffic to   : Alias to Cloudfront Distribution
                        : us-aest-1
                        : Select ALB
Routing policy          : Failover
    failover record type: Primary
    healty check ID     : aws-project-health-check
    Record ID           : blogpage1

---> Click Add another record
record 2
Record name             : www
Record Type             : A - Routes traffic to an IPv4 address and some AWS resources
Alias                   : ok
     Route traffic to   : Alias to S3 website endpoint
                        : us-aest-1
                        : Select www.xxxxxxxxxxx.com
Routing policy          : Failover
    failover record type: Secondary
    healty check ID     : none
    Record ID           : blogpage2


- Click create records.

```

### Step 16: Create DynamoDB Table

Go to the DynamoDB table and click create table button.

- Create DynamoDB table:

```text
Table Name            : awsproject-Dynamo
Partition key         : FileName          (String)
Sort key              : Keep them as are
Other Stuff           : Keep them as are
click Create table
```

### Step 17-18: Create Lambda function

Before we create our Lambda function, we should create an IAM role that we'll use for the Lambda function. Go to the IAM console and select "Role" on the left-hand menu, then click "Create role".

#### Create IAM Role

```text
Select Lambda as trusted entity ---> click Next:Permission
Choose: - AmazonS3fullaccess, 
        - NetworkAdministrator
        - AmazonDynamoDBFullAccess
No tags
Role Name           : awsproject_lambda_Role
Role description    : This role gives permission to lambda to reach S3 and DynamoDB on custom VPC
```

Then, go to the Lambda Console and click "Create function".

#### Create Lambda Function

Basic information
```text
Function Name                   : awsprojectlambdafunction
Runtime                         : Python 3.9
Change default execution role   : Use an existing role(awsproject_lambda_Role)

Additional Configurations:
Enable VPC              : 
    - VPC               : awsproject-VPC
    - Subnets           : Select all subnets
    - Security Group    : Select default Security Group
```
click Create function

Go to the `code` part and select `lambda_function.py`. Remove the default code and paste the code below. If you gave DynamoDB a different name, please make sure to change it in the code.

```python
import json
import boto3

def lambda_handler(event, context):
    # S3 ve DynamoDB'yi başlat
    s3 = boto3.client('s3')
    dynamodb = boto3.resource('dynamodb')
    
    # DynamoDB tablosunun adı
    table_name = 'change me'
    table = dynamodb.Table(table_name)
    
    # Olay verilerinden bucket ve dosya adı bilgilerini al
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        file_name = record['s3']['object']['key']
        
        # İlgili bilgileri DynamoDB'ye kaydet
        response = table.put_item(
            Item={
                'FileName': file_name,
                'BucketName': bucket_name,
                'Timestamp': record['eventTime']
            }
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }
```

- Click deploy and all set. 


### Step 17-18: Create S3 Event and Set It as Trigger for Lambda Function

Go to the S3 console and select the S3 bucket named `awsprojectc3<name>blog`.

- Go to the "properties" menu ---> Go to the Event notifications part.
- Click create event notification for creating an object.

```text
Event Name              : awsproject S3 event
Prefix                  : media/
Suffix                  :Keep them as are
Event Types                :
    - All object create events
    - All object removal events
    - All restore object events
Destination             : Lambda Function
Specify Lambda function : Choose from your Lambda functions 
Lambda function         : awsprojectlambdafunction
click save
```

Go to the website and add a new post with a photo, then check if the record is written on DynamoDB.

- WE ARE ALL SET.

- Congratulations! You have finished your AWS Final Project.
```