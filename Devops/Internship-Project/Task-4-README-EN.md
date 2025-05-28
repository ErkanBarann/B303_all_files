# DevOps Project TASK-4: Kubernetes Cluster Setup and Application Deployment

## Purpose
To set up a Kubernetes cluster on AWS machines provisioned with Terraform and configured with Ansible, then convert a Docker Compose application into Kubernetes manifest files and deploy it onto this cluster. This process will be automatically managed with Jenkins.

## Requirements
- AWS account
- Terraform
- Ansible
- Docker, Docker Compose
- Jenkins
- Git and GitHub (or similar version control system)
- AWS CLI and ECR access
- Kustomize
- Kompose Tool
- Kubernetes(Kubeadm)

## Step-by-Step Tasks

### 1. Creating Key Pair with AWS CLI
1.1. Use AWS CLI to create a new key pair for EC2. This key pair will be used for SSH access to EC2 instances created in subsequent steps.

### 2. Creating Machines for Kubernetes Cluster with Terraform
2.1. Use Terraform to create at least two EC2 instances necessary for Kubernetes, designated as Kubernetes master and node.
2.2. Configure appropriate security groups, IAM roles, and other network settings in the Terraform configuration files for the created instances.

### 3. Configuring Kubernetes Cluster with Ansible
3.1. Use Ansible playbooks to set up a Kubernetes cluster on the created EC2 instances. These playbooks will install Kubernetes packages, initiate the cluster, and add the nodes to the cluster.

### 4. Building Docker Images and Pushing to AWS ECR
4.1. Build the necessary Docker images for your application.
4.2. Push the created Docker images to AWS ECR.

### 5. Converting Docker Compose to Kubernetes Manifests
5.1. Use your Docker Compose file to convert to Kubernetes manifest files using the Kompose tool.
5.2. Update the created Kubernetes manifest files with necessary configurations using Kustomize.

### 6. Deploying the Application with kubectl
6.1. Deploying the application using kubectl from the created manifest files.

### 7. Automation with Jenkins
7.1. Create a `Jenkinsfile` to define a Jenkins pipeline that will automate these processes. The pipeline will cover all steps from setting up the Kubernetes cluster to deploying the application.

### 8. Testing and Verification
8.1. Test to ensure that the application has been successfully deployed on the Kubernetes cluster.
8.2. Conduct necessary tests to ensure the application is functioning correctly.

### 9. Documentation and Reporting
9.1. Document every step, configuration, and script used in the project in detail.
9.2. Report any challenges encountered and their solutions.
