# DevOps Final Project - TASK-6: Kubernetes Management and Monitoring with Rancher and EFK

## Project Goal
This task involves setting up a Kubernetes cluster using the Rancher UI, deploying an application with Helm, managing the cluster with Kubernetes Lens, and monitoring application logs with the EFK (Elasticsearch, Fluentd, Kibana) stack. By completing these steps, you will enhance your skills in managing Kubernetes, deploying applications, and monitoring logs.

## Requirements
- **Cloud Provider**: AWS EC2 (Ubuntu 22.04)
- **Software**: Rancher, Helm, Kubernetes CLI (kubectl), Kubernetes Lens
- **Other Requirements**: SSH access, AWS Route 53 (optional)

## Steps

### 1. Setting up the Environment for Rancher Installation
In the first step, you need to prepare the environment for the Rancher Server installation. You will create an AWS EC2 instance and configure the necessary security groups. Ensure that the required ports are open for Rancher to work correctly. It is recommended to connect to the server via SSH and update the system.

### 2. Creating a Kubernetes Cluster with RKE via Rancher UI
Once the Rancher Server is installed, create a Kubernetes cluster using RKE (Rancher Kubernetes Engine) via the Rancher UI. In this step, you will configure the cluster settings and make it easily manageable using the Rancher UI.

### 3. Deploying an Application to the Cluster with Helm
Deploy an application to the Kubernetes cluster created in the previous step using Helm. This step will involve using a Helm chart to deploy an application and manage it on Kubernetes.

### 4. Viewing the Cluster with Kubernetes Lens
Kubernetes Lens is a powerful interface for managing and monitoring your Kubernetes cluster. In this step, you will install Lens, add your kubeconfig file, and view the Kubernetes cluster created with Rancher.

### 5. Monitoring Logs of the Deployed Application with EFK
The EFK (Elasticsearch, Fluentd, Kibana) stack is used for log collection and analysis in Kubernetes environments. In this step, you will set up EFK to collect logs from your application, route them with Fluentd, and visualize them in Kibana.

## Conclusion
Upon completing this task, you will have learned how to set up a Kubernetes cluster with Rancher, deploy applications with Helm, monitor the cluster with Kubernetes Lens, and track logs with the EFK stack.
