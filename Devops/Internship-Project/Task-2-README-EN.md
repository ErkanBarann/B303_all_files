# DevOps Project TASK-2: AWS Environment Configuration with Ansible and Automation with Jenkins

## Purpose
This project involves using Terraform to create environments in AWS and configuring them using Ansible, managed dynamically via a Jenkins pipeline. This setup automates the environment setup and management process.

## Requirements
- AWS account
- Terraform
- Ansible
- Jenkins
- Git and GitHub

## Step-by-Step Tasks

### 1. Creating Ansible Playbooks
- **1.1.** Create the necessary Ansible playbooks. Include configurations like software installations, user accounts, and security settings.
- **1.2.** Prepare dynamic playbooks that will operate based on environment variables such as for dev, test, staging, and prod environments.

### 2. Integrating Terraform Outputs with Ansible
- **2.1.** Transfer information obtained as Terraform outputs (e.g., EC2 instance IP addresses) to an Ansible inventory file or a dynamic inventory script.
- **2.2.** Set up Ansible playbooks to run using this inventory file.

### 3. Creating and Configuring Jenkinsfile
- **3.1.** Create a Jenkinsfile that includes both Terraform and Ansible processes.
- **3.2.** Add steps in the Jenkins pipeline that run Ansible playbooks following the creation of environments with Terraform.

### 4. Defining Dynamic Parameters in Jenkins Pipeline
- **4.1.** Add parameters in the Jenkins pipeline that can be selected via Jenkins UI, such as the environment.
- **4.2.** Write scripts that execute the relevant Terraform and Ansible commands based on the selected environment.

### 5. Testing and Verification
- **5.1.** Run the Jenkins pipeline for each environment to check if the Terraform and Ansible processes are completed successfully.
- **5.2.** Verify that the environments are configured as desired.

### 6. Documentation and Reporting
- **6.1.** Document each step, configuration, and script used in the project in detail.
- **6.2.** Report any challenges encountered and their solutions.
- **6.3.** Prepare a final report detailing the configured resources and the automation process.
