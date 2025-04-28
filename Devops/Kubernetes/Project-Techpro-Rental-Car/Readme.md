# Kubernetes Project Assignment: Flask App with MySQL and NGINX Ingress

## Objective

In this project, you will convert a Docker Compose project into Kubernetes configurations. You will create Kubernetes resources (such as Pods, Services, Deployments, ConfigMaps, and Ingress) for a Flask application that interacts with a MySQL database and is served via NGINX Ingress.

## Project Overview

You are given a Docker Compose file that defines three services:
- **Flask Application (app)**
- **MySQL Database (db)**
- **NGINX (reverse proxy)**

Your task is to replicate this Docker Compose project in Kubernetes by creating the following components:
1. **Deployments** for the Flask app, MySQL database, and NGINX Ingress Controller.
2. **Services** to expose the Flask app and MySQL database to each other.
3. **Ingress** to expose the Flask app to external traffic via the NGINX Ingress Controller.
4. **Persistent Volumes** to persist MySQL data.
5. **ConfigMaps** and **Secrets** for environment variables like database credentials and API keys.
6. **Namespaces** and **Networking** for isolation and communication between the services.

## Requirements

- **Kubernetes Cluster**: You should have access to a Kubernetes cluster (either locally or using a cloud provider like AWS, Google Cloud, etc.).
- **kubectl**: Ensure `kubectl` is configured to interact with your Kubernetes cluster.
- **NGINX Ingress Controller**: The NGINX Ingress Controller must be installed in your Kubernetes cluster.

## Steps to Complete the Project

1. **Create a Namespace**:
   Create a namespace named `flask-app` to isolate your resources.

2. **Create Deployments**:
   - Create a `Deployment` for the Flask application.
   - Create a `Deployment` for MySQL.
   - Install and configure **NGINX Ingress Controller** in your cluster.

3. **Create Services**:
   - Expose the Flask application as a `ClusterIP` service.
   - Expose the MySQL database as a `ClusterIP` service.

4. **Create Ingress**:
   - Define an **Ingress resource** to expose the Flask application using the NGINX Ingress Controller.
   - The Ingress will handle external HTTP/HTTPS traffic and route it to the Flask app.

5. **Persistent Storage**:
   - Create a `PersistentVolume` and `PersistentVolumeClaim` for MySQL data storage and Flask app.

6. **Environment Variables and Secrets**:
   - Use Kubernetes `ConfigMap` for non-sensitive data (e.g., Flask environment).
   - Use Kubernetes `Secret` for sensitive data (e.g., MySQL credentials).

7. **Networking**:
   - Ensure that the Flask app can communicate with the MySQL service using the appropriate service names.
   - Ensure the NGINX Ingress Controller is correctly configured to route requests to the Flask app.

8. **Install NGINX Ingress Controller**:
   Install the NGINX Ingress Controller in your Kubernetes cluster by running the following command:

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
   ```

9. **Deploy to Kubernetes**:
   - Apply your Kubernetes manifests using `kubectl apply -f`.

## Example Kubernetes Manifests

You can refer to the following manifest examples for your solution:

1. **Flask Deployment** (`flask-deployment.yaml`)
2. **MySQL Deployment** (`mysql-deployment.yaml`)
3. **NGINX Ingress Controller Deployment** (`nginx-ingress-controller.yaml`)
4. **Service for Flask App** (`flask-service.yaml`)
5. **Service for MySQL** (`mysql-service.yaml`)
6. **Ingress for Flask App** (`flask-ingress.yaml`)
7. **PersistentVolumeClaim for MySQL** (`mysql-pvc.yaml`)
8. **ConfigMap and Secrets** (`configmap.yaml`, `secrets.yaml`)

## Ingress Resource Example

Here is an example of a Kubernetes Ingress resource to expose the Flask app via the NGINX Ingress Controller:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: flask-app-ingress
  namespace: flask-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: flask-app.techprodevops.com  # Replace with your domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: flask-service
            port:
              number: 8000
```

This **Ingress** resource will route incoming traffic to the Flask application service (`flask-service`) on port `8000`.

## Submission

- Submit all the Kubernetes YAML files that you have created.
- Include a short description of any changes or configurations you made to adapt the original Docker Compose project to Kubernetes.

Good luck and happy deploying!
```
