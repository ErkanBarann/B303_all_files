# Hands-on ECS : AWS ECS Basics

Purpose of the this hands-on training is to give basic understanding of how to use AWS Elastic Container Service (ECS).

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- prepare a Docker Machine with terraform.

- create and configure AWS ECR from the AWS Management Console.

- demonstrate how to build a docker image with Dockerfile.

- use Docker commands effectively to tag, push, and pull images to/from ECR.

- delete images and repositories on ECR from the AWS Management Console.

- Deploy application to AWS ECS using aws management console, aws cli and aws copilot.

## Outline

- Part 1 - Launching a Docker Machine Instance Configured for ECR Management

- Part 2 - Containerize the Application and Push Image to ECR

- Part 3 - Deploy the Application

- Part 4 - Creating a cluster with a Fargate Linux task using the AWS CLI

- Part 5 - Amazon ECS using AWS Copilot

## Part 1 - Launching a Docker Machine Instance Configured for ECR Management

- Launch a Docker machine on Ubuntu 24.04 AMI with security group allowing SSH connections using the [Cloudformation Template for Docker Machine Installation]
( This CloudFormation Template creates a Docker machine on an EC2 Instance.
  The Docker Machine will run on Ubuntu 24.04 (ami-084568db4383264d4) EC2 Instance with
  a custom security group allowing SSH connections from anywhere on port 22 and HTTP on port 80.
  It also provides full permissions to interact with Amazon ECR.)

## Part 2 - Containerize the Application and Push Image to ECR

### Creating Repository on AWS ECR

- Navigate to the [Amazon ECR console.](https://console.aws.amazon.com/ecs/home?#/repositories).

- Click on `Create Repository` and explain the default `registry` for user account. (`aws_account_id`.dkr.ecr.`region`.amazonaws.com)

- Enter a repository name ex. `techproshop`.

- Keep the other parameters as default.

- Create the repository.

### Creating the Images and Push the ECR 

- connect to your instance with SSH.

```bash
ssh -i .ssh/xxxxx.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

- Check your AWS CLI version `aws --version` command.

- Configure AWS credentials or you can attach `AWS IAM Role` to your EC2 instance.

```bash
aws configure
```

- Authenticate the Docker CLI to your default `registry` 

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <Account id>.dkr.ecr.us-east-1.amazonaws.com
```

- Copy the files given within the hands-on folder [techproshop](./techproshop)  and paste under the `/home/ec2-folder`.

```bash
scp -i <pem-file> -r techproshop ec2-user@<ec2-instance-public-ip>:/home/ec2-user
```

- Go to `techproshop` folder.

```bash
cd techproshop
```

- Explain the `techproshop.py` and `Dockerfile` files.

- Build your Docker image using the following command.

```bash
docker build -t techproshop . (if you get "permission denied" error, then use  "sudo chmod 777 /var/run/docker.sock")
```

- After the build completes, tag your image so you can push the image to this repository.

```bash
docker tag techproshop:latest <account id>.dkr.ecr.us-east-1.amazonaws.com/techproshop:latest
```

- Run the following command to push this image to your newly created AWS repository.

```bash
docker push <account id>.dkr.ecr.us-east-1.amazonaws.com/techproshop:latest
```

## Part 3 - Deploy the Application

### Create an Amazon ECS cluster

- Navigate to the [Amazon ECS console](https://console.aws.amazon.com/ecs/home?).

- From the Amazon ECS left navigation menu, select `Clusters`.

- Select Create `cluster`.

- For the Cluster name, enter `techproshop-ecs`.


- Keep the other parameters as default.

- Click create.

### Write a Task Definition

- Task definitions specify how Amazon ECS deploys the application containers across the cluster.
- Before begin we need to create IAM role:

```bash
Use case : Elastic Container Service >>> Elastic Container Service task
Policy.  : AmazonECSTaskExecutionRolePolicy
Name     : ecsTaskExecutionRole
```

- From the Amazon ECS left navigation menu, select Task Definitions.

- Select Create new Task Definition.

- On the Configure task definition and containers page, do the following:

      - In the Task Definition family field, enter `techproshop-td`.

      - In the Container-1 field:

            - enter `techproshop` to `Name` field,

            - enter `[account-ID].dkr.ecr.[region].amazonaws.com/techproshop:latest` to `Image URI` field.

            - enter `80` to `Container port` field.

            - and click `next`.

- On the Configure environment, storage, monitoring, and tags page, do the following:

      - for `App environment`, select AWS Fargate (serverless).

      - For `CPU`, select `.5 vCPU`.

      - For `Memory`, select `1 GB`.

      - For `Task role`, select `ecsTaskExecutionRole`.

      - Keep the other parameters as default.

      - and click `next`.

- On the Review and create page, just click `create`.

- Your Task Definition is listed in the console.

### Deploy the container as a service into the cluster.

- Navigate to the Amazon ECS console and select Clusters from the left menu bar.

- Select the `techproshop-ecs` cluster, select the Services tab then select Create.

- On the Deploy page, edit the following parameters (and keep the default values for parameters not listed below): 

      - In the `Deployment configuration` field:

            - For the `Task definition` Family select `techproshop-td`,

            - For the `Service Name`, enter `techproshop-service`,

            - For the `Desired tasks`, enter `1`. 

      - In the `Load balancing - optional` field:

            - For Load balancer type, select `Application Load Balancer`.

            - Click Create a new load balancer.

            - For `Load balancer name` enter `techproshop-lb` load balancer.

            - For `Target group` name, enter `techproshop-tg`.

            - For Protocol, select `HTTP`.

            - click Create.

### Check your Application is Running.

- Navigate to the [Load Balancer section](https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:).

- Select `techproshop-lb` load balancer.

- In the Description field copy DNS name and paste the browser and see the application.

## Part 4 - Creating a cluster with a Fargate Linux task using the AWS CLI

- Create your own cluster with a unique name with the following command.

```bash
aws ecs create-cluster --cluster-name cluster-with-awscli
```

### Register a Linux Task Definition

- Before you can run a task on your ECS cluster, you must register a task definition. Task definitions are lists of containers grouped together. The following example is a simple task definition that creates a simple web app using the python:alpine container image.

- Create a file and name it as `techproshop-task.json` under `techproshop` folder.

```json
{
	"family": "techproshop-task-awscli",
	"networkMode": "awsvpc",
	"containerDefinitions": [{
		"name": "techproshop-app",
		"image": "[account-ID].dkr.ecr.us-east-1.amazonaws.com/techproshop:latest",
		"portMappings": [{
			"containerPort": 80,
			"protocol": "tcp"
		}],
		"essential": true
	}],
	"requiresCompatibilities": [
		"FARGATE"
	],
	"cpu": "256",
	"memory": "512",
      "executionRoleArn": "arn:aws:iam::[account-ID]:role/ecsTaskExecutionRole"
}
```

- Register the task definition with the following command.

```bash
aws ecs register-task-definition --cli-input-json file://techproshop-task.json
```

- List the task definitions. The output of this command shows the family and revision values that you can use together when calling run-task or start-task.

```bash
aws ecs list-task-definitions
```

### Create a Service

- After you have registered a task for your account, you can create a service for the registered task in your cluster. 

```bash
aws ecs create-service --cluster cluster-with-awscli --service-name techproshop-service --task-definition techproshop-task-awscli --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[subnet-08bde4ae867355fbf],securityGroups=[sg-0024abd65de858178],assignPublicIp=ENABLED}"
```

- List the services for your cluster. 

```bash
aws ecs list-services --cluster cluster-with-awscli
```

- Describe the service.

```bash
aws ecs describe-services --cluster cluster-with-awscli --services techproshop-service
```

- Delete the service.

```bash
aws ecs delete-service --cluster cluster-with-awscli --service techproshop-service --force
```

- Delete the cluster.

```bash
aws ecs delete-cluster --cluster cluster-with-awscli
```

## Part 5 - Amazon ECS using AWS Copilot

- The AWS Copilot CLI is a tool for developers to build, release and operate production ready containerized applications on AWS App Runner, Amazon ECS, and AWS Fargate.

- Install the AWS Copilot CLI

```bash
sudo curl -Lo /usr/local/bin/copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux \
   && sudo chmod +x /usr/local/bin/copilot \
   && copilot --help
```

- AWS Copilot walks you through the setup of your first application and service with a series of terminal prompts, starting with next step.

```bash
cd techproshop
copilot init
```

- Name your application.

```bash
What would you like to name your application? [? for help]
```

- Enter `techproshop`.

- You're prompted to choose a service type. You're building a simple Flask application that serves a small web page.

```bash
Which workload type best represents your architecture? [Use arrows to move, type to filter, ? for more help]
   > Load Balanced Web Service
     Backend Service
     Scheduled Job
```

- Choose `Load Balanced Web Service`.

- Provide a name for your service.

```bash
What do you want to name this service? [? for help] 
```

- Enter `techproshop-service` for your service name.

- Select a Dockerfile.

```bash
Which Dockerfile would you like to use for api? [Use arrows to move, type to filter, ? for more help]
   > ./Dockerfile
     Use an existing image instead
```

- Choose `Dockerfile`.

- After the application resources are created, deploy a test environment.

```bash
Would you like to deploy a test environment? [? for help] (y/N)
```

- Enter `y`.

- You will see a log displaying the status of your application deployment.

- List all of your AWS Copilot applications.

```bash
copilot app ls
```

- Show information about the environments and services in your application.

```bash
copilot app show
```

- Show information about your environments.

```bash
copilot env ls
```y

- Show information about the service, including endpoints, capacity and related resources.

```bash
copilot svc show
```

- List of all the services in an application.

```bash
copilot svc ls
```

- Show logs of a deployed service.

```bash
copilot svc logs
```

- Show service status.

```bash
copilot svc status
```

- Delete all resources.

```bash
copilot app delete
```
