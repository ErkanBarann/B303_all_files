# Hands-on CW-01 : Setting Cloudwatch Alarm Events, and Logging

Purpose of the this hands-on training is to create Dashboard, Cloudwatch Alarm, configure Events option and set Logging up.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- create Cloudwatch Dashboard.

- settings Cloudwatch metrics.

- create an Alarm.

- create an Events.

- configure Logging with Agent.


## Outline

- Part 1 - Prep - Launching an Instance

- Part 2 - Creating a Cloudwatch dashboard

- Part 3 - Creating an Alarm

- Part 4 - Creating an Events with Lambda

- Part 5 - Configure Logging with Agent 

## Part 1 - Prep - Launching an Instance

STEP 1 : Create a EC2

- Go to EC2 menu using AWS console

- Launch an Instance
- Configuration of instance.

```text
AMI             : Amazon Linux 2
Instance Type   : t2.micro
Tag             :
    Key         : Name
    Value       : Cloudwatch_Instance
Security Group ---> Allows ssh, http, https to anywhere
Advanced Details
Detailed CloudWatch monitoring: Select "Enable"
```
- Set user data.

```bash
#! /bin/bash
yum update -y
amazon-linux-extras install nginx1.12
yum install git -y
systemctl start nginx
cd /usr/share/nginx/html
git clone https://github.com/techproedu/designer.git
chmod -R 777 /usr/share/nginx/html
rm index.html
cp -R ./designer/. .
systemctl restart nginx
systemctl enable nginx
```

## Part 2 - Creating a Cloudwatch dashboard

STEP 1: Create Dashboard

- Go to the Cloudwatch Service from AWS console.

- Select Dashboards from left hand pane

- Click "Create Dashboard"
```
Dashboard Name: techproed_Dashboard
```

- Select a widget type to configure as "Line"  ---> Next

- Select "Metrics"  ----> Tap configure button

- Select "EC2" as a metrics

- Select "Per-instance" metrics

- Select "Cloudwatch_Instance", "CPUUtilization"  ---> Click "create widget"
 Click "save"

STEP 2: Upload Stress tool on EC2

- Connect to the EC2 via ssh

- Upload Stress tool and run it

```bash
sudo amazon-linux-extras install epel -y
sudo yum install -y stress
stress --cpu 100 --timeout 20000 
```

- It takes a while to install stress

- Show that EC2 CPUUtilization Metrics increased

- go to terminal and stop the stress tool using "Ctrl+C" command

## Part 3 - Create an Alarm.

- Select Alarms on left hand pane

- click "Create Alarm"

- Click "Select metric"

- Select Metric  ---> EC2 ---> Per-Instance Metrics ---> Instance ID ---> "CPUUtilization" ---> Select metric

```bash
Metric      : change "period" to 1 minute and keep remaining as default
Conditions  : 
  - Treshold Type                 : Static
  - Whenever CPUUtilization is... : Greater
  - than...                       : 60
```

- click next

```bash
Notification:
  - Alarm state trigger : In alarm
  Send a notification to the following SNS topic : 
    - Create new topic
      - Create a new topic… : techpro-alarm
      - Email endpoints that will receive the notification…
: <your email address>
    - create topic

EC2 action
  - Alarm state trigger
    - In alarm ---> Select "Stop Instance"
```

- click next

- Alarm Name  : My First Cloudwatch Alarm
  Description : My First Cloudwatch Alarm

- click next --- > review and click create alarm

- go to email box and confirm the e-mail sent by AWS Cloudwatch service

- go to the terminal and connect EC2 instance via ssh

- start the stress tool:

```bash
stress --cpu 100 --timeout 20000
```
- Go to dashboard and check the EC2 metrics

- you will receive a alarm message to your email and this message trigger to stop your EC2 Instance.

- go to EC2 instance list and show the stopped instance 

- delete Alarm

- restart this instance.

### Part 4 - CloudWatch Events with Lambda

#### Step 1: Create Role

- Go to IAM console a create Policy named "start-stop-instance" including these json script seen below:

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Start*",
                "ec2:Stop*"
            ],
            "Resource": "*"
        }
    ]
}

```
- than create a IAM Role that will be used in Lambda Function 

- Click Roles on left hand pane

- click create role

- select Lambda ---> click next permission

- select newly created Policy named "start-stop-instance"  ---> Next

- Add tags ---> Next

- Review
	- Role Name :start-stop-instance
  - Role Description: start-stop-instance
 -lambda
- click create role

#### Step 2: Creating Stop Lambda Functions

- Go to Lambda Service on AWS Console

- Functions ----> Create Lambda function
```text
1. Select Author from scratch
  Name: Stop_Instance
  Runtime: Python 3.9
  Role: 
    Existing Role: "start-stop instance"
  Click 'Create function'
```

- Configuration of Function Code

- In the sub-menu of configuration go to the "Function code section" and paste code seen below

```python
import boto3
region = 'us-east-1'
instances = ['i-02c107da60f5dad15']#DON'T FORGET TO CHANGE ME
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))

```
- Don't forget to change Instance ID in the Code. 

- Click "DEPLOY" button


#### Step 3 Testing your function - Create test event

Click 'Test' button and opening page Configure test events
```
Select: Create new test event
Event template: Hello World
Event name: teststop
Input test event as;

{}

Click 'Create'
Click 'Test'
```
You will see the message Execution result: 

- Than check the EC2 instance that it it stopped. 

#### Step 4: Creating Start Lambda Functions

- Go to Lambda Service on AWS Console

- Functions ----> Create Lambda function
```text
1. Select Author from scratch
  Name: Start_Instance
  Runtime: Python 3.9
  Role: 
    Existing Role: "start-stop-instance"
  Click 'Create function'
```

- Configuration of Function Code

- In the sub-menu of configuration go to the "Function code section" and paste code seen below

```python
import boto3
region = 'us-east-1'
instances = ['i-02c107da60f5dad15']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))
```

- Don't forget to change Instance ID in the Code. 

- Click "DEPLOY" button

#### Step 5 Testing your function - Create test event

Click 'Test' button and opening page Configure test events
```
Select: Create new test event
Event template: Hello World
Event name: teststart
Input test event as;

{}

Click 'Create'
Click 'Test'
```
You will see the message Execution result: 

- Than check the EC2 instance that it will be restarted thanks to the Lambda 

#### Step 6 Creating Stop-Cloudwatch Event

- Go to the CloudWatch Console and from left hand menu under the Event sub-section
- Click on "Rules" 
Event Bus -------> Default(keep it as is)
Rules     -------> Create Rule 
Click on "Create Rule"
```
- Name                   : event_stop
- Description - optional : event_stop
- Event Bus              : Default(keep it as is)
- Rule type              : "Schedule"
--------> Continue to create rule
```
- Click on Next

- Define schedule

```text
- Sample event     :  Keep it as is
- Schedule pattern : A fine-grained schedule 
                    Cron expression: 45 19 * * ? * 
                    Note: (- Explain the cron parameters. 
                           - Choose Local Time 
                           - Change cron expression according to session time to be triggered within 3 minutes.)

```

- Click on "Next: "

- Select the Target parameters:

```text
Targets: 
- AWS service
- Select Target: Lambda Function
                   - Function: Stop_Instance

```
- Click on "Next "
- Click "Configure tags"
- Click "Create Rule."

Show the Instance state that Event is gonna stop instance. 

#### Step 7 Creating Start-Cloudwatch Event

- Go to the CloudWatch Console and from left hand menu under the Event sub-section
- Click on "Amazon EventBridgeGo" 
Event Bus -------> Default(keep it as is)
Rules     -------> Create Rule 
Click on "Create Rule"
```
- Name                   : event_start
- Description - optional : event_start
- Event Bus              : Default(keep it as is)
- Rule type              : "Schedule"
- Continue to "Create rule" (Left Bottom)>>> Not EventBridge Scheduler!!!!!!!
```
- Click on Next

- Define schedule

```text
- Sample event     :  Keep it as is
- Schedule pattern : A fine-grained schedule 
                    Cron expression: 50 19 * * ? * 
                    Note: (- Explain the cron parameters. 
                           - Choose Local Time 
                           - Change cron expression according to session time to be triggered within 3 minutes.)

```

- Click on "Next: "

- Select the Target parameters:

```text
Targets: 
- AWS service
- Select Target: Lambda Function
                   - Function: Start_Instance

```
- Click on "Next "
- Click "Configure Details"
- Click "Create Rule."

- Show the Instance state that Event is gonna start instance. 

event Delete

### Part 5 - Configure Logging with Agent 

## STEP 1 : Create second EC2 Instance

- Go to EC2 menu using AWS console

- Launch an Instance
- Configuration of instance.

```text
AMI             : Amazon Linux 2
Instance Type   : t2.micro
Tag             :
    Key         : Name
    Value       : Cloudwatch_Log
Security Group ---> Allows all traffic --->  anywhere
```
- Set user data.

```bash
#! /bin/bash
yum update -y
amazon-linux-extras install nginx1.12
yum install git -y
systemctl start nginx
cd /usr/share/nginx/html
git clone https://github.com/techproedu/designer.git
chmod -R 777 /usr/share/nginx/html
rm index.html
cp -R ./designer/. .
systemctl restart nginx
systemctl enable nginx
```

## STEP 2 : Create IAM role

- Go to `IAM role` on AWS console

- Click Roles on left hand pane

- click create role

- select EC2 ---> click next permission

- select "CloudWatchLogsFullAccess"  ---> Next

- Add tags ---> Next

- Review
	- Role Name : techprocloudwatchlog  
  - Role Description: techproed Cloudwatch EC2 logs access role

- click create role

- Go to instance  ---> Actions ---> Security ---> Modify IAM role ---> Attach "techprocloudwatchlog" role ---> Apply

### STEP 3:  Install and Configure the CloudWatch Logs Agent

- Go to the terminal and connect to the Instance named "Cloudwatch_Log"

- install cloudwatch log agent with following command:
```bash
sudo yum install -y awslogs
sudo systemctl start awslogsd
sudo systemctl enable awslogsd.service
```
- go to the Cloudwatch menu and select Log groups on left hand pane

  Cloudwatch >> Log groups
- click the created log group named "/var/log/messages" ---> show the newly created "log streams"
stop
start
## STEP 4: Configure Nginx logs

- go to the terminal and connect to the EC2 Instance named "Cloudwatch_Log" with ssh

- go to the "awslogs" folder using "cd /etc/awslogs/" command

- use the root account
```bash
cd /etc/awslogs/
sudo su
ls
```
awscli.conf  awslogs.conf  config  proxy.conf

- open the file named awslogs.conf

```bash
vim awslogs.conf
```

- at the bottom of the page you'll see the following comments:

```bash
[/var/log/messages]
datetime_format = %b %d %H:%M:%S
file = /var/log/messages
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/messages
```

- press "I" and paste the following command right after command seen above: 

```bash

[/var/log/nginx/access.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/access.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = AccessLog

[/var/log/nginx/error.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/error.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = ErrorLog
```

- save the file and close
```bash
:wq
```

- to activate the new configuration, stop and start the "awslogsd".

```bash
sudo systemctl stop awslogsd
sudo systemctl start awslogsd
```
- Go to the EC2 instance and grab the public IP address. And paste it to the browser. Their logs will be sent to the cloudwatch logs part.

- go to the Cloudwatch logs group ---> /var/log/messages again 

- click the created log group named "AccessLog" and "ErrorLog" ---> show the newly created "log streams"

- If you get any problem try to restart instance .

 Delete
 ınstance
 CloudWatch
 Dashboards
 All alarms
 Log groups
 lambda Functions
 rol
 EventBridge








