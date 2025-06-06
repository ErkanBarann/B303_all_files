# Hands-on Kubernetes-06: Deploying Microservices and Service Level Autoscaling

Purpose of the this hands-on training is to give students the knowledge of  Autoscaling and Microservices

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Understand deployment and management of microservices

- Explain the Kubernetes Autoscaling

- Explain Horizontal Pod Autoscaler Business Logic

- Understand the Need for Metric Server

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Outline of the Hands-on Setup

- Part 3 - Microservices

- Part 4 - Autoscaling in Kubernetes

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 24.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster]. *Note: Once the master node up and running, worker node automatically joins the cluster.*

>*Note: If you have problem with kubernetes cluster, you can use this link for lesson.*
>https://killercoda.com/playgrounds

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get no
```

## Part 2 - Outline of the Hands-on Setup

- First one is simple web&database application to hold the to-do-lists. This sub-application uses MongoDB to store to-do lists created through the web application. For the front-end web application layer, Node.JS is used. Thus, this sub-aplication has 2 microservices.

- Create a `microservices` directory and `to-do` directory in the microservices directory and change directory.

```bash
mkdir microservices
cd microservices
mkdir to-do
cd to-do
```

### Steps of execution:

1. We will deploy the `to-do` app first and look at some key points.
2. The Autoscaling in Kubernetes will be  demonstrated as a last step.

## Part 3 - Microservices

- The MongoDB application will use a static volume provisioning with the help of persistent volume (PV) and persistent volume claim (PVC). 

- Create a `db-pv.yaml` file.

```bash
mkdir kube-files
cd kube-files
touch db-pv.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv-vol
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/home/ubuntu/pv-data"
```

- Create a `db-pvc.yaml` file.

```bash
touch db-pvc.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-persistent-volume-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 1Gi
```

- It will provision storage from `hostpath`.

- Let's create the MongoDB deployment yaml file (name it `db-deployment.yaml`) to see how the PVC is used. 

```bash
touch db-deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-deployment
  labels:
    app: todoapp
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
        - containerPort: 27017
        volumeMounts:
          - name: mongo-storage
            mountPath: /data/db
      volumes:
        #- name: mongo-storage
        #  hostPath:
        #    path: /home/ubuntu/pv-data
        - name: mongo-storage
          persistentVolumeClaim:
            claimName: database-persistent-volume-claim
```

- The commented part directly uses the local hostpath for storage. Students can try it on their own later.

- Let's create the MongoDB `service` and name it `db-service.yaml`.

```bash
touch db-service.yaml
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

- Note that a database has no direct exposure the outside world, so it's type is `ClusterIP`.

- Now, create the `web-deployment.yaml` for web application.

```bash
touch web-deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: todoapp
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
        - image: techproawsdevopsteam/todo:v1
          imagePullPolicy: Always
          name: myweb
          ports: 
            - containerPort: 3000
          env:
            - name: "DBHOST"
              value: db-service
          resources:
            limits:
              memory: 500Mi
              cpu: 100m
            requests:
              memory: 250Mi
              cpu: 80m		  
```
- Note that this web app is connnected to MongoDB host/service via the `DBHOST` environment variable. What does `db-service:27017` mean here. How is the IP resolution handled?

- When should we use `imagePullPolicy: Always`. Explain the `image` pull policy shortly.

- This time, we create the `web-service.yaml` for front-end web application `service`.

```bash
touch web-service.yaml
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
  type: NodePort
  ports:
   - name: http
     port: 3000
     targetPort: 3000
     nodePort: 30001
     protocol: TCP

```

- What should be the type of the service? ClusterIP, NodePort or LoadBalancer?

- Let's deploy the to-do application.

```bash
cd ..
kubectl apply -f kube-files
```

```bash
deployment.apps/db-deployment created
persistentvolume/db-pv-vol created
persistentvolumeclaim/database-persistent-volume-claim created
service/db-service created
deployment.apps/web-deployment created
service/web-service created
```
Note that we can use `directory` with `kubectl apply -f` command.

Check the persistent-volume and persistent-volume-claim.

```bash
$ kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS   REASON   AGE
db-pv-vol   5Gi        RWO            Retain           Bound    default/database-persistent-volume-claim   manual                  23s

$ kubectl get pvc
NAME                               STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE
database-persistent-volume-claim   Bound    db-pv-vol   5Gi        RWO            manual         56s
```

Check the pods.
```bash
$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
db-deployment-8597967796-q7x5s    1/1     Running   0          4m30s
web-deployment-658cc55dc8-2h2zc   1/1     Running   2          4m30s
```

Check the services.
```bash
$ kubectl get svc
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
db-service    ClusterIP   10.105.0.75     <none>        27017/TCP        4m39s
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP          2d8h
web-service   NodePort    10.107.136.54   <none>        3000:30001/TCP   4m38s
```

- Note the `PORT(S)` difference between `db-service` and `web-service`. Why?

- We can visit http://<worker-public-node-ip>:<node-port> and access the application. Note: Do not forget to open the Port <node-port> in the security group of your node instance.

- We see the home page. You can add to-do's.


## Part 4 - Autoscaling in Kubernetes

### Benefits of Autoscaling
To understand better where autoscaling would provide the most value, let’s start with an example. Imagine you have a 24/7 production service with a load that is variable in time, where it is very busy during the day in the US, and relatively low at night. Ideally, we would want the number of nodes in the cluster and the number of pods in deployment to dynamically adjust to the load to meet end user demand. The new Cluster Autoscaling feature together with Horizontal Pod Autoscaler can handle this for you automatically.


### Create Horizontal Pod Autoscaler   

- Now that the server is running, we will create the autoscaler using kubectl autoscale. ( https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details ) for more details on the algorithm.

Now activate the  HPAs; 


```bash
kubectl autoscale deployment web-deployment --cpu-percent=50 --min=3 --max=5 
```
or we can use yaml files.


```bash
$ cat << EOF > hpa-web.yaml

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-deployment
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-deployment
  minReplicas: 3
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

EOF
```

```bash
kubectl apply -f hpa-web.yaml
```

Let's look at the status:
```bash
watch -n3 kubectl get service,hpa,pod -o wide 
```

Every 3,0s: kubectl get service,hpa,pod -o wide                                                                       ubuntu: Sat Sep 12 17:48:18 2020

NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE     SELECTOR
service/db-service           ClusterIP   10.105.0.75     <none>        27017/TCP        105m    name=mongo
service/kubernetes           ClusterIP   10.96.0.1       <none>        443/TCP          2d10h   <none>
service/web-service          NodePort    10.107.136.54   <none>        3000:30001/TCP   105m    name=web

NAME                                             REFERENCE                   TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/web          Deployment/web-deployment   <unknown>/50%   3         5         3          76s

NAME                                  READY   STATUS    RESTARTS   AGE    IP           NODE       NOMINATED NODE   READINESS GATES
pod/db-deployment-8597967796-q7x5s    1/1     Running   0          105m   172.18.0.5   minikube   <none>           <none>
pod/web-deployment-658cc55dc8-2h2zc   1/1     Running   2          105m   172.18.0.4   minikube   <none>           <none>
pod/web-deployment-658cc55dc8-88nxz   1/1     Running   0          61s    172.18.0.8   minikube   <none>           <none>
pod/web-deployment-658cc55dc8-c7hdl   1/1     Running   0          61s    172.18.0.9   minikube   <none>           <none>
```
- web-deployment Pod number increased to 3, minimum number. 
- The HPA line under TARGETS shows `<unknown>/50%`. The `unknown` means the HPA can't idendify the current use of CPU.


We may check the current status of autoscaler by running:  
```bash
kubectl get hpa
NAME         REFERENCE                   TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
web          Deployment/web-deployment   <unknown>/50%   3         5         3          117s
```

```bash
kubectl describe hpa
```

Reference:                                             Deployment/web-deployment
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  <unknown> / 50%
....
Conditions:
  Type           Status  Reason                   Message
  ----           ------  ------                   -------
  AbleToScale    True    SucceededGetScale        the HPA controller was able to get the target's current scale
  ScalingActive  False   FailedGetResourceMetric  the HPA was unable to compute the replica count: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
.....

- The `metrics` can't be calculated. So, the `metrics server` should be uploaded to the cluster.

### Install Metric Server 

- First Delete the existing Metric Server if any.

```bash
kubectl delete -n kube-system deployments.apps metrics-server
```

- Get the Metric Server form [GitHub](https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.6.3).

```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.3/components.yaml
```

- Edit the file `components.yaml`. You will select the `Deployment` part in the file. Add the below line to `containers.args field under the deployment object`.

```yaml
        - --kubelet-insecure-tls
``` 
(We have already done for this lesson)

```yaml
apiVersion: apps/v1
kind: Deployment
......
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
......	
```

- Add `metrics-server` to your Kubernetes instance.

```bash
kubectl apply -f components.yaml
```
- Wait 1-2 minute or so.

- Verify the existace of `metrics-server` run by below command

```bash
kubectl -n kube-system get pods
```

- Verify `metrics-server` can access resources of the pods and nodes.

```bash
kubectl top pods
NAME                              CPU(cores)   MEMORY(bytes)   
db-deployment-8597967796-8lwzr    6m           140Mi                     
web-deployment-6d8d8c777b-2fr9h   1m           22Mi            
web-deployment-6d8d8c777b-z5xd2   1m           24Mi              
```

```bash         
kubectl top nodes
NAME     CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
master   188m         9%     1245Mi          32%
node1    108m         5%     1035Mi          27% 
```

```bash
kubectl get hpa
NAME         REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
web          Deployment/web-deployment   2%/50%    3         5         3          15m
```
- Look at the the values under TARGETS. The values are changed from `<unknown>/50%` to `1%/50%` & `2%/50%`, means the HPA can now idendify the current use of CPU.

- If it is still `<unknown>/50%`, check the `spec.template.spec.containers.resources.request` field of deployment.yaml files. It is required to define this field. Otherwise, the autoscaler will not take any action for that metric. 

> For per-pod resource metrics (like CPU), the controller fetches the metrics from the resource metrics API for each Pod targeted by the HorizontalPodAutoscaler. Then, if a target utilization value is set, the controller calculates the utilization value as a percentage of the equivalent resource request on the containers in each Pod.
 
> Please note that if some of the Pod's containers do not have the relevant resource request set, CPU utilization for the Pod will not be defined and the autoscaler will not take any action for that metric.

### Increase load

- Now, we will see how the autoscaler reacts to increased load. We will start a container, and send an infinite loop of queries to the web-service (please run it in a different terminal): 

- First look at the services.

```bash
kubectl get svc
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
db-service           ClusterIP      10.97.2.64      <none>        27017/TCP        23m
kubernetes           ClusterIP      10.96.0.1       <none>        443/TCP          18d
web-service          NodePort       10.96.115.134   <none>        3000:30001/TCP   23m
```

```bash
kubectl run -it --rm load-generator --image=busybox /bin/sh  
/ # while true; do wget -q -O- http://<worker puplic ip>:<port number of web-service> > /dev/null; done
```

Watch table
```bash
watch -n3 kubectl get service,hpa,pod -o wide

Every 3.0s: kubectl get service,hpa,pod -o wide                                                                     master: Thu Sep 17 11:29:19 2020

NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE   SELECTOR
service/db-service           ClusterIP      10.97.2.64      <none>        27017/TCP        48m   name=mongo
service/kubernetes           ClusterIP      10.96.0.1       <none>        443/TCP          18d   <none>
service/web-service          NodePort       10.96.115.134   <none>        3000:32040/TCP   48m   name=web

NAME                                             REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/web          Deployment/web-deployment   62%/50%   3         5         3          36m

NAME                                  READY   STATUS    RESTARTS   AGE     IP               NODE    NOMINATED NODE   READINESS GATES
pod/db-deployment-8597967796-h952d    1/1     Running   0          48m     172.16.166.160   node1   <none>           <none>
pod/load-generator                    1/1     Running   0          4m19s   172.16.166.129   node1   <none>           <none>
pod/web-deployment-6d8d8c777b-2nf9x   1/1     Running   0          8s      172.16.166.188   node1   <none>           <none>
pod/web-deployment-6d8d8c777b-hh2t4   1/1     Running   0          36m     172.16.166.157   node1   <none>           <none>
pod/web-deployment-6d8d8c777b-q9c4t   1/1     Running   0          36m     172.16.166.172   node1   <none>           <none>
pod/web-deployment-6d8d8c777b-tgkzc   1/1     Running   0          48m     172.16.166.159   node1   <none>           <none>
```

### Stop load

- We will finish our example by stopping the user load.

- In the terminal where we created the container with busybox image, terminate the load generation by typing `Ctrl` + `C`. Close the load introducing terminals grafecully and observe the behaviour at the watch board.

- Then we will verify the result state (after a minute or so):
  
```bash
kubectl get hpa 
```
  
```bash
kubectl get deployment
```

# References: 
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

https://www.digitalocean.com/community/tutorials/webinar-series-deploying-and-scaling-microservices-in-kubernetes