# Hands-on Kubernetes-05: Managing Secrets and ConfigMaps

Purpose of the this hands-on training is to give students the knowledge of Kubernetes Secrets and config-map

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Explain the Kubernetes Secrets

- Share sensitive data (such as passwords) using Secrets.

- Learn configuration management for applications in Kubernetes using ConfigMaps.

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Kubernetes Secrets

- Part 3 - ConfigMaps in Kubernetes

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 24.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster]. *Note: Once the master node up and running, worker node automatically joins the cluster.*

>*Note: If you have problem with kubernetes cluster, you can use this link for lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get no
```

## Part 2 - Kubernetes Secrets

## Creating your own Secrets 

### Creating a Secret manually

- You can also create a Secret in a file first, in JSON or YAML format, and then create that object. The name of a Secret object must be a valid DNS subdomain name. The Secret contains two maps: data and stringData. The data field is used to store arbitrary data, encoded using base64. The stringData field is provided for convenience, and allows you to provide secret data as unencoded strings.

- For example, to store two strings in a Secret using the data field, convert the strings to base64 as follows:

```bash
echo -n 'admin' | base64
```

- The output is similar to:

```bash
YWRtaW4=
```

```bash
echo -n '1f2d1e2e67df' | base64
```

- The output is similar to:

```bash
MWYyZDFlMmU2N2Rm
```

- Write a Secret that looks like this named `secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```

- Now create the Secret using `kubectl apply`:

```bash
kubectl apply -f ./secret.yaml
```

- The output is similar to:

```bash
secret "mysecret" created
```

### Decoding a Secret

- Secrets can be retrieved by running kubectl get secret. For example, you can view the Secret created in the previous section by running the following command:

```bash
kubectl get secret mysecret -o yaml
```

- The output is similar to:

```yaml
apiVersion: v1
data:
  password: MWYyZDFlMmU2N2Rm
  username: YWRtaW4=
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"password":"MWYyZDFlMmU2N2Rm","username":"YWRtaW4="},"kind":"Secret","metadata":{"annotations":{},"name":"mysecret","namespace":"default"},"type":"Opaque"}
  creationTimestamp: "2021-10-06T12:51:08Z"
  name: mysecret
  namespace: default
  resourceVersion: "38986"
  uid: fb55a84e-24f5-461d-a000-e7dab7c34200
type: Opaque
```

- Decode the password field:

```bash
echo 'MWYyZDFlMmU2N2Rm' | base64 --decode 
```

- The output is similar to:

```bash
1f2d1e2e67df
```

### Using Secrets

- Firstly we get the parameters as plain environment variable.

- Create a file named `mysecret-pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        value: admin
      - name: SECRET_PASSWORD
        value: 1f2d1e2e67df
  restartPolicy: Never
```

- Create the pod.

```bash
kubectl apply -f mysecret-pod.yaml
```

- Connect the pod and check the environment variables.

```bash
kubectl exec -it secret-env-pod -- bash
root@secret-env-pod:/data# echo $SECRET_USERNAME
admin
root@secret-env-pod:/data# echo $SECRET_PASSWORD
1f2d1e2e67df
root@secret-env-pod:/data# exit
```

- Delete the pod.

```bash
kubectl delete -f mysecret-pod.yaml
```

- This time we get the environment variables from secret objects. Modify the mysecret-pod.yaml as below.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
  restartPolicy: Never
```

- Update the pod.

```bash
kubectl apply -f mysecret-pod.yaml
```

### Consuming Secret Values from environment variables

- Inside a container that consumes a secret in an environment variables, the secret keys appear as normal environment variables containing the base64 decoded values of the secret data. This is the result of commands executed inside the container from the example above:

- Enter into pod and type following command.

```bash
kubectl exec -it secret-env-pod -- bash
root@secret-env-pod:/data# echo $SECRET_USERNAME
admin
root@secret-env-pod:/data# echo $SECRET_PASSWORD
1f2d1e2e67df
root@secret-env-pod:/data# exit
```

## Part 3 - ConfigMaps in Kubernetes

- A ConfigMap is a dictionary of configuration settings. This dictionary consists of key-value pairs of strings. Kubernetes provides these values to your containers. Like with other dictionaries (maps, hashes, ...) the key lets you get and set the configuration value.

- A ConfigMap stores configuration settings for your code. Store connection strings, public credentials, hostnames, environment variables, container command line arguments and URLs in your ConfigMap.

- ConfigMaps bind configuration files, command-line arguments, environment variables, port numbers, and other configuration artifacts to your Pods' containers and system components at runtime.

- ConfigMaps allow you to separate your configurations from your Pods and components. 

- ConfigMap helps to makes configurations easier to change and manage, and prevents hardcoding configuration data to Pod specifications.

- ConfigMaps are useful for storing and sharing non-sensitive, unencrypted configuration information.

- For the show case we will select a simple application that displays a message like this.

```text
Hello, Techpro!
```

- We will parametrized the "Hello" portion in some languages.

```bash
mkdir k8s
cd k8s/
```

- Create 2 files.

```bash
touch deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
  labels:
    app: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name: demo
          image: techprodevops348/demo:hello2
          ports:
          - containerPort: 80
```

```bash
touch service.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-service
  labels:
    app: demo
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001    
  selector:
    app: demo
```

- See the files and go upper folder.

```bash
ls
deployment.yaml  service.yaml
cd .. 
```

- Now apply `kubectl` to these files.

```bash
kubectl apply -f k8s
```

Let's see the message.

```bash
kubectl get svc demo-service -o wide
NAME           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
demo-service   NodePort       10.105.148.115   <none>     80:30001/TCP   43s      app=demo

curl < worker-ip >:30001
Hello, Techpro!
```
This is the default container behaviour.

Now delete what we have created.

```bash
kubectl delete -f k8s
```

- We have modified the application to take the greeting message as a parameter (environmental variable). So we will expose configuration data into the container’s environmental variables. Firstly, let's see how to pass environment variables to pods.

- Modify the `deployment.yaml` as below.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name:  demo
          image: techprodevops348/demo:hello-config-env-latest
          ports:
            - containerPort: 80
          env:
            - name: GREETING
              value: selam
```

- Now apply `kubectl` to these files.

```bash
kubectl apply -f k8s
```

Let's see the message.

```bash
kubectl get svc demo-service -o wide
NAME           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
demo-service   NodePort       10.105.148.115   <none>        80:30001/TCP   43s   app=demo

curl < worker-ip >:30001
selam, Techpro!
```
This is the default container behaviour.

Now delete what we have created.

```bash
kubectl delete -f k8s
```

- This time we will expose configuration data into the container’s environmental variables. And,  we will create `ConfigMap` and use the `greeting` key-value pair as in the `deployment.yaml` file.

## Creating a ConfigMap manually

- We will create the `configmap.yaml` as follows:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
data:
  greeting: Hola
```

- We will update the `deployment.yaml` as follows:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name:  demo
          image: techprodevops348/demo:hello-config-env-latest
          ports:
            - containerPort: 80
          env:
            - name: GREETING
              valueFrom:
                configMapKeyRef:
                  name: demo-config
                  key: greeting
```

- Create the objects.

```bash
kubectl apply -f k8s

kubectl get svc
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
demo-service   NodePort    10.102.145.186   <none>        80:30001/TCP   5s
kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        14h

curl < worker-ip >:30001
Hola, Techpro
```

- Reset what we have created.

```bash
kubectl delete -f k8s
```

## Configure all key-value pairs in a ConfigMap as container environment variables in POSIX format

- In case if you are using envFrom  instead of env  to create environmental variables in the container, the environmental names will be created from the ConfigMap's keys. If a ConfigMap  key has invalid environment variable name, it will be skipped but the pod will be allowed to start. 

Modify configmap.yaml file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
data:
  GREETING: Merhaba
```

The environmental variables are directly filled in `configmap.yaml`. They are in capital letters.

- `deployment.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name:  demo
          image: techprodevops348/demo:hello-config-env-latest
          ports:
            - containerPort: 80
          envFrom:
          - configMapRef:
              name: demo-config
```

Note the change as follows:

```yaml
...
          envFrom:
          - Ref:
              name: demo-config
```

- You can compare with the previos `deployment.yaml` file.

```bash
kubectl apply -f k8s
```

```bash
kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
demo-service   NodePort    10.98.123.146   <none>        80:30001/TCP   5s
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        62m

curl < worker-ip >:30001
Merhaba, Techpro!
```

Everything works fine!

```bash
kubectl delete -f k8s
```

### From a config file

Modify configmap.yaml and deployment.yaml file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
data:
  config: |-
    Hei
```


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name:  demo
          image: techprodevops348/demo:hello-config-env-latest
          ports:
            - containerPort: 80
          env:
            - name: GREETING
              valueFrom:
                configMapKeyRef:
                  name: demo-config
                  key: config
```

```bash
kubectl apply -f k8s
```

```bash
kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
demo-service   NodePort    10.98.123.146   <none>        80:30001/TCP   5s
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        62m

curl < worker-ip >:30001
Hei, Techpro!
```

Everything works fine!

```bash
kubectl delete -f k8s
```

### Creating volume from configmap

- Creating a volume from a ConfigMap in Kubernetes means making the data stored in the ConfigMap accessible via the file system to the containers in a Pod. This method is an efficient way to dynamically provide configuration files or environment variables to your application. In the pod definition, you specify the ConfigMap as a volume and mount this volume into containers. Thus, the data in the ConfigMap can be accessed as a file.

Modify configmap.yaml, service.yaml and deployment.yaml file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - name: web-volume
              mountPath: /usr/share/nginx/html
      volumes:
        - name: web-volume
          configMap:
            name: web-config
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-service
  labels:
    app: demo
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001    
  selector:
    app: web-server
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
data:
  index.html: |
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Techproeducation</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 0; color: #333; }
            .header { background-color: #007bff; color: white; padding: 10px 0; text-align: center; }
            .nav-menu { list-style-type: none; padding: 0; overflow: hidden; background-color: #333; }
            .nav-menu li { float: left; }
            .nav-menu li a { display: block; color: white; text-align: center; padding: 14px 16px; text-decoration: none; }
            .nav-menu li a:hover { background-color: #111; }
            .main { padding: 15px; }
            .main img { max-width: 100%; height: auto; }
            .footer { background-color: #f1f1f1; text-align: center; padding: 10px 0; }
        </style>
    </head>
    <body>

    <div class="header">
        <h1>Techproeducation</h1>
    </div>

    <ul class="nav-menu">
        <li><a href="#home">Home</a></li>
        <li><a href="#courses">Courses</a></li>
        <li><a href="#testimonials">Testimonials</a></li>
        <li><a href="#contact">Contact</a></li>
    </ul>

    <div class="main">
        <img src="https://techproeducation.com/logo/headerlogo.svg" alt="Tech Education Image">

        <h2>Welcome to Techproeducation</h2>
        <p>Your journey to mastering technology starts here. Explore our courses and programs to find your path.</p>
        
        <h3 id="courses">Our Courses</h3>
        <!-- Course information can be added here -->

        <h3 id="testimonials">Testimonials</h3>
        <!-- Testimonials can be added here -->
    </div>

    <div class="footer">
        <p>Contact us at info@techproeducation.com</p>
        <p>Follow us on <a href="#">Facebook</a>, <a href="#">Twitter</a>, and <a href="#">LinkedIn</a></p>
    </div>

    </body>
    </html>
```

```bash
kubectl apply -f k8s
```

```bash
kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
demo-service   NodePort    10.98.123.146   <none>        80:30001/TCP   5s
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        62m
```

```bash
curl < worker-ip >:30001
or 
http://< worker-ip >:30001
```

Everything works fine!

```bash
kubectl delete -f k8s
```