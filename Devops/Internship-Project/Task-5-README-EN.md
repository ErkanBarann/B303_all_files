# DevOps Final Project TASK-5: Application Deployment on AWS EKS with Helm

## Purpose
This project involves deploying an application on AWS EKS using Helm, setting up Nginx Ingress, and deploying the Prometheus-Grafana monitoring stack. This process will be automatically managed with Jenkinsfile.

## Requirements
- AWS account
- AWS CLI
- kubectl
- eksctl
- Helm
- Jenkins
- Git ve GitHub
- AWS EKS
- AWS ECR
- Prometheus
- Grafana

## Step-by-Step Tasks

### 1. Helm and EKS CLI Configuration
1.1. Ensure that AWS CLI, kubectl, and Helm are installed on your local machine.
1.2. Use `aws eks update-kubeconfig --region region-code --name cluster-name` to connect to your AWS EKS cluster.

### 2. Nginx Ingress Installation
2.1. Install the Nginx Ingress controller using Helm:
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-basic --create-namespace

### 3. Application Deployment
3.1. Prepare your application's Helm chart or use an existing one.
3.2. Deploy your application to the EKS cluster using Helm:
helm upgrade --install my-application ./path-to-your-chart --namespace your-namespace

### 4. Prometheus-Grafana Monitoring Stack Installation
4.1. Install the Kube Prometheus Stack for Prometheus and Grafana:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

### 5. Automation with Jenkinsfile
5.1. Create a Jenkinsfile to automate all these deployment processes. Configure the necessary helm install and helm upgrade commands within the Jenkinsfile.

### 6. Testing and Verification
6.1. Verify that your application and monitoring services are working correctly.
6.2. Test access to your application via Nginx Ingress.

### 7. Documentation and Reporting
7.1. Document every step, configuration, and script used in the project in detail.
7.2. Report any challenges encountered and their solutions.
