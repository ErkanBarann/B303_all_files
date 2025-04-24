# Hands-on EKS-02 : Dynamic Volume Provisionining and Ingress

Purpose of the this hands-on training is to give students the knowledge of  Dynamic Volume Provisionining and Ingress.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Learn to Create and Manage EKS Cluster with eksctl.

- Explain the need for persistent data management

- Learn PersistentVolumes and PersistentVolumeClaims

- Understand the Ingress and Ingress Controller Usage

## Outline

- Part 1 - Installing kubectl and eksctl on Amazon Linux 2023

- Part 2 - Creating the Kubernetes Cluster on EKS

- Part 3 - Dynamic Volume Provisionining

- Part 4 - Ingress

## Prerequisites

1. AWS CLI with Configured Credentials

2. kubectl installed

3. eksctl installed

For information on installing or upgrading eksctl, see [Installing or upgrading eksctl.](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html#installing-eksctl)

## Part 1 - Installing kubectl and eksctl on Amazon Linux 2023

### Install kubectl

- Launch an AWS EC2 instance of Amazon Linux 2023 AMI with security group allowing SSH.

- Connect to the instance with SSH.

- Update the installed packages and package cache on your instance.

```bash
sudo yum update -y
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \$ "
bash
```

- Download the Amazon EKS vended kubectl binary.

```bash
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl
```

- Apply execute permissions to the binary.

```bash
chmod +x ./kubectl
```

- Copy the binary to a folder in your PATH. If you have already installed a version of kubectl, then we recommend creating a $HOME/bin/kubectl and ensuring that $HOME/bin comes first in your $PATH.

```bash
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
```

- (Optional) Add the $HOME/bin path to your shell initialization file so that it is configured when you open a shell.

```bash
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
```

- After you install kubectl , you can verify its version with the following command:

```bash
kubectl version --client
```


### Install eksctl

- Download and extract the latest release of eksctl with the following command.

https://eksctl.io/installation/

```bash
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
```

- The eksctl executable is placed in $HOME/bin, which is in $PATH from Git Bash.

```bash
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
```

- Test that your installation was successful with the following command.

```bash
eksctl version
```

## Part 2 - Creating the Kubernetes Cluster on EKS

- If needed create ssh-key with command `ssh-keygen -f ~/.ssh/id_rsa`.

```bash
ssh-keygen -f ~/.ssh/id_rsa
Enter passphrase (empty for no passphrase): Enter
Enter same passphrase again: Enter
```

- Configure AWS credentials. Or you can attach `AWS IAM Role` to your EC2 instance.

```bash
aws configure
```
```bash
  aws configure
  AWS Access Key ID [None]: xxxxxxx
  AWS Secret Access Key [None]: xxxxxxxx
  Default region name [None]: us-east-1
  Default output format [None]: json
```

- Explain the deault values. 

```bash
aws eks list-clusters
eksctl create cluster --help
```

- Create an EKS cluster via `eksctl`. It will take a while.

```bash
eksctl create cluster \
  --name techpro-cluster \
  --region us-east-1 \
  --zones us-east-1a,us-east-1b,us-east-1c \
  --nodegroup-name my-nodes \
  --node-type t3a.medium \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 3 \
  --ssh-access \
  --ssh-public-key ~/.ssh/id_rsa.pub \
  --managed \
  --node-volume-size 10
```

or 

```bash
eksctl create cluster --region us-east-1 --zones us-east-1a,us-east-1b,us-east-1c --node-type t3a.medium --nodes 2 --nodes-min 2 --nodes-max 3 --name techpro-cluster
```

- Show the aws `eks service` on aws management console and explain `eksctl-my-cluster-cluster` stack on `cloudformation service`.

## Part 3 - Dynamic Volume Provisionining

### The Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver

- The Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver allows Amazon Elastic Kubernetes Service (Amazon EKS) clusters to manage the lifecycle of Amazon EBS volumes for persistent volumes.

- The Amazon EBS CSI driver isn't installed when you first create a cluster. To use the driver, you must add it as an Amazon EKS add-on or as a self-managed add-on. 

- Install the Amazon EBS CSI driver. For instructions on how to add it as an Amazon EKS add-on, see Managing the [Amazon EBS CSI driver as an Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html).

### Creating an IAM OIDC provider for your cluster

- To use AWS EBS CSI, it is required to have an AWS Identity and Access Management (IAM) OpenID Connect (OIDC) provider for your cluster. 

- Determine whether you have an existing IAM OIDC provider for your cluster. Retrieve your cluster's OIDC provider ID and store it in a variable.

```bash
oidc_id=$(aws eks describe-cluster --name techpro-cluster --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
```

- Determine whether an IAM OIDC provider with your cluster's ID is already in your account.

```bash
aws iam list-open-id-connect-providers | grep $oidc_id
```
If output is returned from the previous command, then you already have a provider for your cluster and you can skip the next step. If no output is returned, then you must create an IAM OIDC provider for your cluster.

- Create an IAM OIDC identity provider for your cluster with the following command. Replace my-cluster with your own value.

```bash
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=techpro-cluster --approve
```

### Creating the Amazon EBS CSI driver IAM role for service accounts

- The Amazon EBS CSI plugin requires IAM permissions to make calls to AWS APIs on your behalf. 

- When the plugin is deployed, it creates and is configured to use a service account that's named ebs-csi-controller-sa. The service account is bound to a Kubernetes clusterrole that's assigned the required Kubernetes permissions.

#### To create your Amazon EBS CSI plugin IAM role with eksctl

- Create an IAM role and attach the required AWS managed policy with the following command. Replace cw-cluster with the name of your cluster. The command deploys an AWS CloudFormation stack that creates an IAM role, attaches the IAM policy to it, and annotates the existing ebs-csi-controller-sa service account with the Amazon Resource Name (ARN) of the IAM role.

```bash
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster techpro-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole
```

### Adding the Amazon EBS CSI add-on

#### To add the Amazon EBS CSI add-on using eksctl

- Run the following command. Replace techpro-cluster with the name of your cluster, 111122223333 with your account ID, and AmazonEKS_EBS_CSI_DriverRole with the name of the IAM role created earlier.


```bash
eksctl create addon --name aws-ebs-csi-driver --cluster techpro-cluster --service-account-role-arn arn:aws:iam::111122223333:role/AmazonEKS_EBS_CSI_DriverRole --force
```

- Firstly, check the StorageClass object in the cluster. 

```bash
kubectl get sc
kubectl describe sc/gp2
```

- Create a StorageClass with the following settings.

https://kubernetes.io/docs/concepts/storage/storage-classes/

```bash
vim storage-class.yaml
```

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: aws-standard
provisioner: kubernetes.io/aws-ebs
volumeBindingMode: WaitForFirstConsumer   # immediate
parameters:
  type: gp2
  fsType: ext4           
```

```bash
kubectl apply -f storage-class.yaml
```

- Explain the default storageclass

```bash
kubectl get storageclass
NAME             PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
aws-standard     kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  37s
gp2 (default)    kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  112m
```

- Create a persistentvolumeclaim with the following settings and show that new volume is created on aws management console.

```bash
vim techpro-pv-claim.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: techpro-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
  storageClassName: aws-standard
```

```bash
kubectl apply -f techpro-pv-claim.yaml
```

- List the pv and pvc and explain the connections.

```bash
kubectl get pv,pvc,sc
```
- You will see an output like this

```text
NAME                                    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/techpro-pv-claim   Pending                                      aws-standard   11s
```

- Create a pod with the following settings.

```bash
vim pod-with-dynamic-storage.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-aws
  labels:
    app : web-nginx
spec:
  containers:
  - image: nginx:latest
    ports:
    - containerPort: 80
    name: test-aws
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: aws-pd
  volumes:
  - name: aws-pd
    persistentVolumeClaim:
      claimName: techpro-pv-claim
```

```bash
kubectl apply -f pod-with-dynamic-storage.yaml
watch kubectl get pv,pvc,sc
```

- Enter the pod and see that ebs is mounted to  /usr/share/nginx/html path.

```bash
kubectl exec -it test-aws -- bash
```
- You will see an output like this
```text
root@test-aws:/# df -h
Filesystem      Size  Used Avail Use% Mounted on
overlay          80G  3.5G   77G   5% /
tmpfs            64M     0   64M   0% /dev
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
/dev/xvda1       80G  3.5G   77G   5% /etc/hosts
shm              64M     0   64M   0% /dev/shm
/dev/xvdcj      2.9G  9.1M  2.9G   1% /usr/share/nginx/html
tmpfs           2.0G   12K  2.0G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs           2.0G     0  2.0G   0% /proc/acpi
tmpfs           2.0G     0  2.0G   0% /proc/scsi
tmpfs           2.0G     0  2.0G   0% /sys/firmware
root@test-aws:/# exit
```

- Delete the storageclass that we create.

```bash
kubectl get storageclass
```
```text
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
aws-standard    kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  71m
gp2 (default)   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  4h10m
```


```bash
kubectl delete storageclass aws-standard
```

- Delete the pod

```bash
kubectl delete -f pod-with-dynamic-storage.yaml
kubectl delete -f techpro-pv-claim.yaml
kubectl get pv,pvc,sc
```

## Part 4 - Ingress

https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/ 

```bash
mkdir -p ingress-yaml-files/php-apache ingress-yaml-files/to-do && touch ingress-yaml-files/ingress-service.yaml ingress-yaml-files/php-apache/php-apache.yaml ingress-yaml-files/to-do/db-deployment.yaml ingress-yaml-files/to-do/db-pvc.yaml ingress-yaml-files/to-do/db-service.yaml ingress-yaml-files/to-do/web-deployment.yaml ingress-yaml-files/to-do/web-service.yaml
```
The directory structure is as follows:

```text
ingress-yaml-files
├── ingress-service.yaml
├── php-apache
│   └── php-apache.yaml
└── to-do
    ├── db-deployment.yaml
    ├── db-pvc.yaml
    ├── db-service.yaml
    ├── web-deployment.yaml
    └── web-service.yaml
```

### Steps of execution:

1. We will deploy the `to-do` app first and look at some key points.
2. And then deploy the `php-apache` app and highlights some important points.
3. We will introduce the `ingress-service` and talk about it.

Let's check the state of the cluster and see that everything works fine.

```bash
kubectl cluster-info
kubectl get node
```

- Go to `ingress-yaml-file/to-do` folder and paste the following content into the `db-service.yaml` file
```bash
cd ingress-yaml-files/to-do
vim db-service.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-service
  labels:
    name: mongo
    app: todoapp
spec:
  selector:
    name: mongo
  type: ClusterIP
  ports:
    - name: db
      port: 27017
      targetPort: 27017
```

Note that a database has no direct exposure the outside world, so it's type is `ClusterIP`.


- Paste the following content into the `web-service.yaml` file

```bash
vim web-service.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
  labels:
    name: web
    app: todoapp
spec:
  selector:
    name: web 
  type: LoadBalancer
  ports:
   - name: http
     port: 3000
     targetPort: 3000
     protocol: TCP
```
What should be the type of the service? ClusterIP, NodePort or LoadBalancer?

- Paste the following content into the `web-deployment.yaml` file

```bash
vim web-deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      name: web
  template:
    metadata:
      labels:
        name: web
        app: todoapp
    spec:
      containers: 
        - image: techprodevops348/todo
          imagePullPolicy: Always
          name: myweb
          ports: 
            - containerPort: 3000
          env:
            - name: "DBHOST"
              value: "db-service:27017"
          resources:
            limits:
              cpu: 100m
            requests:
              cpu: 80m
```

- Paste the following content into the `db-deployment.yaml` file

```bash
vim db-deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      name: mongo
  template:
    metadata:
      labels:
        name: mongo
        app: todoapp
    spec:
      containers:
      - image: mongo:5.0
        name: mongo
        ports:
        - name: mongo
          containerPort: 27017
        volumeMounts:
          - name: mongo-storage
            mountPath: /data/db
      volumes:
        #- name: mongo-storage
        #  hostPath:
        #    path: /data/db
        - name: mongo-storage
          persistentVolumeClaim:
            claimName: database-persistent-volume-claim
```     

- Paste the following content into the `db-pvc.yaml` file

```bash
vim db-pvc.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-persistent-volume-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: gp2
```

Let's deploy the to-do application.

```bash
cd ..
kubectl apply -f to-do
deployment.apps/db-deployment created
persistentvolumeclaim/database-persistent-volume-claim created
service/db-service created
deployment.apps/web-deployment created
service/web-service created
```
Note that we can use `directory` with `kubectl apply -f` command.

- Check the pods.
```bash
kubectl get po,deploy,svc,pvc
```
- You will see an output like this

```text
NAME                              READY   STATUS    RESTARTS   AGE
db-deployment-8597967796-q7x5s    1/1     Running   0          4m30s
web-deployment-658cc55dc8-2h2zc   1/1     Running   2          4m30s
```

- Check the services.
```bash
kubectl get svc
```
- You will see an output like this

```text
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)          AGE
db-service           ClusterIP      10.100.199.214   <none>                                                                    27017/TCP        22m
kubernetes           ClusterIP      10.100.0.1       <none>                                                                    443/TCP          120m
web-service          LoadBalancer   10.100.59.43     a2a513b28b46b4a20848f8303294e90f-1926642410.us-east-2.elb.amazonaws.com   3000:31860/TCP   22m
```
Note the `PORT(S)` difference between `db-service` and `web-service`. Why?

- We can visit a2a513b28b46b4a20848f8303294e90f-1926642410.us-east-2.elb.amazonaws.com:3000 and access the application.

or

```bash
curl a2a513b28b46b4a20848f8303294e90f-1926642410.us-east-2.elb.amazonaws.com:3000 
```
We see the home page. You can add to-do's.

- Now deploy the second application

- Paste the following content into the `php-apache.yaml` file

```bash
cd php-apache/
vim php-apache.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 100m
          requests:
            cpu: 80m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache-service
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache 
  type: LoadBalancer	
```

Note how the `Deployment` and `Service` `yaml` files are merged in one file. 

- Deploy this `php-apache` file.

```bash
kubectl apply -f php-apache.yaml 
```

- Get the pods.

```bash
kubectl get po,svc
```
- You will see an output like this
```text
NAME                              READY   STATUS    RESTARTS   AGE
db-deployment-8597967796-q7x5s    1/1     Running   0          17m
php-apache-7869bd4fb-xsvnh        1/1     Running   0          24s
web-deployment-658cc55dc8-2h2zc   1/1     Running   2          17m
```

- Get the services.

```bash
kubectl get svc
```
- You will see an output like this

```text
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)          AGE
db-service           ClusterIP      10.100.199.214   <none>                                                                    27017/TCP        22m
kubernetes           ClusterIP      10.100.0.1       <none>                                                                    443/TCP          120m
php-apache-service   LoadBalancer   10.100.191.10    ac4c071f935d64c3cb535e87e50c8216-186981612.us-east-2.elb.amazonaws.com    80:31850/TCP     59m
web-service          LoadBalancer   10.100.59.43     a2a513b28b46b4a20848f8303294e90f-1926642410.us-east-2.elb.amazonaws.com   3000:31860/TCP   22m
```

Let's check what web app presents us.

- On opening browser (ac4c071f935d64c3cb535e87e50c8216-186981612.us-east-2.elb.amazonaws.com ) we see

```text
OK!
```

Alternatively, you can use;
```bash
curl ac4c071f935d64c3cb535e87e50c8216-186981612.us-east-2.elb.amazonaws.com 
OK!
```

## Ingress

Briefly explain ingress and ingress controller. For additional information a few portal can be visited like;

- https://kubernetes.io/docs/concepts/services-networking/ingress/
  
- https://banzaicloud.com/blog/k8s-ingress/

- https://github.com/nginx/kubernetes-ingress
  
- Open the offical [ingress-nginx]( https://kubernetes.github.io/ingress-nginx/deploy/ ) explain the `ingress-controller` installation steps for different architecture.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml
```

- Now, check the contents of the `ingress-service`.

- Paste the following content into the `ingress-service.yaml` file.

```bash
cd ..
vim ingress-service.yaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-service
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /    
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port: 
                  number: 3000
          - path: /load
            pathType: Prefix
            backend:
              service:
                name: php-apache-service
                port: 
                  number: 80
```

- Explain the rules part.

```bash
kubectl apply -f ingress-service.yaml
```
- You will see an output like this

```bash
kubectl get svc,ing
NAME              HOSTS   ADDRESS                                                                            PORTS   AGE
ingress-service   *       a26be57ce12e64883a5ad050025f2c5b-94ab4c4b033cf5fa.elb.eu-central-1.amazonaws.com   80      2m8s
```

On browser, type this  ( a26be57ce12e64883a5ad050025f2c5b-94ab4c4b033cf5fa.elb.eu-central-1.amazonaws.com ), you must see the to-do app web page. If you type `a26be57ce12e64883a5ad050025f2c5b-94ab4c4b033cf5fa.elb.eu-central-1.amazonaws.com/load`, then the apache-php page, "OK!". Notice that we don't use the exposed ports at the services.

- Delete the cluster

```bash
eksctl get cluster --region us-east-1
```
- You will see an output like this

```text
NAME            REGION          EKSCTL CREATED
techpro-cluster us-east-1       True
```
```bash
kubectl delete -f ingress-service.yaml
kubectl delete -f to-do/
kubectl delete -f php-apache/
eksctl delete cluster techpro-cluster --region us-east-1
```

- Do no forget to delete related ebs volumes.
