# DevOps Project TASK-3: Application Deployment on AWS with Docker Compose

## Purpose
This project involves deploying a multi-service web application on AWS machines provisioned with Terraform and configured with Ansible, using Docker Compose. This process will be automatically managed with Jenkins.

## Requirements
- AWS account
- Terraform
- Ansible
- Docker, Docker Compose
- Jenkins
- Git and GitHub (or a similar version control system)
- AWS CLI and ECR access

## Step-by-Step Tasks

### 1. Creating Dockerfiles
- Create Dockerfiles for the backend and frontend. These Dockerfiles will be used to build the container images for your application.

### 2. Pushing Docker Images to AWS ECR
- Create a new repository in AWS ECR and build and push your Docker images there.

### 3. Docker Compose Configuration
- Create a `docker-compose.yml` file. This file will define how the backend and frontend services communicate with each other and the ports they will be accessible on.

### 4. Automation with Jenkins
- Create a `Jenkinsfile` to define your pipeline. This pipeline will include steps to build Docker images, push them to ECR, and deploy them on AWS using Docker Compose. (This will also incorporate the Jenkinsfile contents from TASK-1 and TASK-2.)

### 5. Testing and Verification
- Test to ensure that the deployed application is functioning correctly.

### Additional Information
- This task is built upon TASK-1 (Creation of infrastructure with Terraform) and TASK-2 (Configuration of infrastructure with Ansible). Therefore, it is expected that you have successfully completed these tasks.
