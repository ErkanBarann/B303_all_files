# Hands-on Kubernetes-12: Helm Basics

The purpose of this hands-on training is to give students the knowledge of basic operations of Helm.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Learn basic operations of Helm

- Learn how to create Helm Chart

- Learn how to use Github as helm repo

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Set up a Helm v3 chart repository in Github

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 24.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster]. *Note: Once the master node up and running, worker node automatically joins the cluster.*

>*Note: If you have a problem with the Kubernetes cluster, you can use this link for the lesson.*
>https://killercoda.com/playgrounds

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get node
```

## Part 2 - Set up a Helm v3 chart repository in Github

- Create a GitHub repo and name it `Helm-Application-Repo`.

- Produce GitHub Apps Personal access tokens. Go to <your avatar> --> Settings --> Developer settings and click Personal access tokens. Make sure to copy your personal access token now. You won’t be able to see it again!

- Let's clone github repository

```bash
git clone https://TOKEN@github.com/USERNAME/Helm-Application-Repo.git
```

### first chart

- Create a new chart with following command.

```bash
helm create todochart
```
- See the files of todoapp.

```bash
ls todochart
```

- Remove the files from `templates` folder.

```bash
rm -rf todochart/templates/*
```

- Create a `todoapp.yaml` file under `techpro-chart/templates` folder with following content.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: todoapp
spec:
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
      - name: myweb

        image: techproawsdevopsteam/todoapp:v1
        ports:
        - containerPort: 3000
        env:
          - name: "DBHOST"
            value: db-service
        livenessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        startupProbe:
          tcpSocket:
            port: 3000
          failureThreshold: 5
          periodSeconds: 12
          initialDelaySeconds: 10
        resources:
          limits:
            memory: 500Mi
            cpu: 100m
          requests:
            memory: 250Mi
            cpu: 80m	
      initContainers:
        - name: wait-for-db
          image: busybox
          command: ['sh', '-c', 'until nc -z db-service 27017; do echo "Waiting for DB"; sleep 2; done;']
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: todoapp
  type: NodePort
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30001

---
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
      - name: mongo
        image: mongo:5.0
        readinessProbe:
          tcpSocket:
            port: 27017
          initialDelaySeconds: 10
          periodSeconds: 20
        resources:
        ports:
        - containerPort: 27017
        volumeMounts: 
          - name: mongo-storage
            mountPath: /data/db

      volumes:
        - name: mongo-storage
          persistentVolumeClaim:
            claimName: database-persistent-volume-claim


---
apiVersion: v1
kind: Service
metadata:
  name: db-service
spec:
  selector:
    app: todoapp
  type: ClusterIP  
  ports:
  - port: 27017
    targetPort: 27017
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv-vol
  labels:
    type: local
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: "/home/ubuntu/pv-data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-persistent-volume-claim
spec:
  resources:
    requests:
      storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
```

- Package the repo under the `Helm-Application-Repo` folder.

```bash
cd Helm-Application-Repo
helm package ../todochart
```

- Generate an index file in the current directory.

```bash
helm repo index .
```

- Commit and push the repo.

```bash
git config --global user.email "you@example.com"
git add .
git commit -m "todochart is added"
git push
```

- Add this repo to your repos. Go to <your repo> --> README.md and click Raw. Copy to address without README.md like below. This will be repo url.

```
https://raw.githubusercontent.com/<github-user-name>/Helm-Application-Repo/main
```
- List the repos and add Helm-Application-Repo.

```bash
helm repo list
helm repo add  Helm-Application-Repo 'https://raw.githubusercontent.com/<github-user-name>/Helm-Application-Repo/main'
helm repo list
```

- Let's search the repo.

```bash
helm search repo Helm-Application-Repo
```

- Create a `README.md` file under `Helm-Application-Repo` folder with following content.

```markdown
## Helm Repository Ekleme ve Uygulama Kurulumu

### 1. Helm Repository Ekleme

```bash
helm repo add Helm-Application-Repo 'https://raw.githubusercontent.com/<github-user-name>/Helm-Application-Repo/main'
```

### 2. Todo Uygulamasını Kurma

```bash
helm install github-repo-release-todo Helm-Application-Repo/todochart
```

### 3. Guestbook Uygulamasını Kurma

```bash
helm install github-repo-release-guest Helm-Application-Repo/Guestbook
```

```

- Commit and push the repo.

```bash
git add .
git commit -m "README file is added"
git push
```

- Create a release from Helm-Application-Repo

```bash
helm install github-repo-release-todo Helm-Application-Repo/todochart
```

- Check the objects.

```bash
kubectl get deployment
kubectl get svc
```

- open the browser and enter worker public ip and 30001 port

<worker_public_ip:30001>

- Uninstall the release.

```bash
helm uninstall github-repo-release-todo
```
### second chart

- Add new charts the repo.

```bash
cd ..
helm create Guestbook
```
- See the files of Guestbook.

```bash
ls Guestbook
```

- Remove the files from `templates` folder.

```bash
rm -rf ls Guestbook/templates/*
```

- Create a `guest.yaml` file under `Guestbook/templates` folder with following content.

---
# SOURCE: https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-leader
  labels:
    app: redis
    role: leader
    tier: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
        role: leader
        tier: backend
    spec:
      containers:
      - name: leader
        image: "docker.io/redis:6.0.5"
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379

---

# SOURCE: https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook
apiVersion: v1
kind: Service
metadata:
  name: redis-leader
  labels:
    app: redis
    role: leader
    tier: backend
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: leader
    tier: backend

---
# SOURCE: https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-follower
  labels:
    app: redis
    role: follower
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
        role: follower
        tier: backend
    spec:
      containers:
      - name: follower
        image: us-docker.pkg.dev/google-samples/containers/gke/gb-redis-follower:v2
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379

---
# SOURCE: https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook
apiVersion: v1
kind: Service
metadata:
  name: redis-follower
  labels:
    app: redis
    role: follower
    tier: backend
spec:
  ports:
    # the port that this service should serve on
  - port: 6379
  selector:
    app: redis
    role: follower
    tier: backend

---
# SOURCE: https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
        app: guestbook
        tier: frontend
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: us-docker.pkg.dev/google-samples/containers/gke/gb-frontend:v5
        env:
        - name: GET_HOSTS_FROM
          value: "dns"
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 80

---
# SOURCE: https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # if your cluster supports it, uncomment the following to automatically create
  # an external load-balanced IP for the frontend service.
  # type: LoadBalancer
  type: NodePort
  ports:
    # the port that this service should serve on
  - port: 80
  selector:
    app: guestbook
    tier: frontend

- Package the repo under the `Helm-Application-Repo` folder.

```bash
cd Helm-Application-Repo
helm package ../Guestbook
```

- Generate an index file in the current directory.

```bash
helm repo index .
```

- Commit and push the repo.

```bash
git add .
git commit -m "Guestbook chart is added"
git push
```

```
- List the repos and update Helm-Application-Repo.

```bash
helm repo list
helm repo update
```

- Let's search the repo.

```bash
helm search repo Helm-Application-Repo
```

- Create a release from Helm-Application-Repo

```bash
helm install github-repo-release-guestbook Helm-Application-Repo/Guestbook
```

- Check the objects.

```bash
kubectl get deployment
kubectl get svc
```

- open the browser and enter worker public ip and frontend svc port

<worker_public_ip:frontendsvcport>

- Uninstall the release.

```bash
helm uninstall github-repo-release-guestbook
```
- Remove the repo.

```bash
helm repo remove Helm-Application-Repo
```