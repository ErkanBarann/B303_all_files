# Hands-on Docker-04 : Docker Image Basic Operations

Purpose of this hands-on training is to give the students understanding to images in Docker.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- explain what Docker image is.

- explain Docker image layers.

- list images in Docker.

- explain Docker Hub.

- have a Docker Hub account and create a repository.

- pull Docker images.

- explain image tags.

- inspect Docker image.

- search for Docker images.

- explain what the Dockerfile is.

- build images with Dockerfile.

- push images to Docker Hub.

- delete Docker images.

## Outline

- Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Part 2 - Using Docker Image Commands and Docker Hub

- Part 3 - Building Docker Images with Dockerfile

## Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Launch a Docker machine on UBUNTU:24.04 AMI with security group allowing SSH connections.

- Connect to your instance with SSH.

```bash
ssh -i "XXXXXXXX.pem" ubuntu@ec2-54-221-179-114.compute-1.amazonaws.com
```

### Docker Installation Using the Convenience Script

```bash
sudo apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
docker --version
sudo usermod -aG docker $USER
newgrp docker
systemctl status docker
docker run hello-world
```

## Part 2 - Using Docker Image Commands and Docker Hub

- Explain what the Docker Hub is.

- Sign up to Docker Hub and explain the UI.

- Create a repository with the name of `flask-app` and description of `This image repo holds Flask apps.`.

- Check if the docker service is up and running on EC2 instance.

```bash
systemctl status docker
```

- List images in Docker and explain properties of images.

```bash
docker image ls
docker images
```

- Download Docker image `ubuntu` and explain image tags (defaults to `latest`) on Docker Hub. Show `ubuntu` repo on Docker Hub and which version the `latest` tag corresponds to (`24.04`).

```bash
# Defaults to ubuntu:latest
docker image pull ubuntu
docker image ls
```

- Run `ubuntu` as container with interactive shell open.

```bash
docker run -it ubuntu
```

- Display the `ubuntu` os info on the container (`VERSION="24.04 LTS (Noble Numbat)"`) and note that the `latest` tag is showing release `24.04` as in the Docker Hub. Then exit the container.

```bash
cat /etc/os-release
exit
```

- Download earlier version (`18.04`) of `ubuntu` image, which is tagged as `18.04` on Docker Hub and explain image list.

```bash
docker image pull ubuntu:18.04
docker image ls
```

- Inspect `ubuntu` image and explain properties.

```bash
# Defaults to ubuntu:latest
docker image inspect ubuntu
# Ubuntu with tag 18.04
docker image inspect ubuntu:18.04
```

- Search for Docker Images both on `bash` and on Docker Hub. 
  
```bash
docker search ubuntu
```

## Part 3 - Building Docker Images with Dockerfile

- Build an image of Python Flask app with Dockerfile based on `python:alpine` image and push it to the Docker Hub.

- Create a folder to hold all files necessary for creating Docker image.

```bash
mkdir techpro_web
cd techpro_web
```

- Create application code and save it to file, and name it `welcome.py`

```bash
echo '
from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "<h1>Welcome to TechPro Education AWS-DEVOPS Team</h1>"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
' > welcome.py
```

- Create a Dockerfile listing necessary packages and modules, and name it `Dockerfile`.

```Dockerfile
FROM ubuntu
RUN apt-get update -y
RUN apt-get install python3 -y
RUN apt-get install python3-pip -y
RUN apt install python3-flask -y
COPY . /app
WORKDIR /app
EXPOSE 80
CMD python3 ./welcome.py
```

- Build Docker image from Dockerfile locally, tag it as `<Your_Docker_Hub_Account_Name>/<Your_Image_Name>:<Tag>` and explain steps of building. Note that repo name is the combination of `<Your_Docker_Hub_Account_Name>/<Your_Image_Name>`.

```bash
docker build -t "techproawsdevopsteam/flask-app:1.0" .
docker image ls
```

- Run the newly built image as container in detached mode, connect host `port 80` to container `port 80`, and name container as `welcome`. Then list running containers and connect to EC2 instance from the browser to show the Flask app is running.

```bash
docker run -d --name welcome -p 80:80 techproawsdevopsteam/flask-app:1.0
docker container ls
```

- Login in to Docker with credentials.

```bash
docker login -u techproawsdevopsteam
```

- Push newly built image to Docker Hub, and show the updated repo on Docker Hub.

```bash
docker push techproawsdevopsteam/flask-app:1.0
```

### This time, we reduce the size of image.

- Create application code and save it to file, and name it `welcome_alpine.py`

```bash
echo '
from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "<h1>Welcome to TechPro Education AWS-DEVOPS Team Alpine</h1>"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
' > welcome_alpine.py
```

- Create a Dockerfile listing necessary packages and modules, and name it `Dockerfile-alpine`
  
```Dockerfile
FROM python:alpine
RUN pip install flask
COPY . /app
WORKDIR /app
EXPOSE 80
CMD ["python", "welcome_alpine.py"]
```

- Build Docker image from Dockerfile locally, tag it as `<Your_Docker_Hub_Account_Name>/<Your_Image_Name>:<Tag>` and explain steps of building. Note that repo name is the combination of `<Your_Docker_Hub_Account_Name>/<Your_Image_Name>`.

```bash
docker build -t "techproawsdevopsteam/flask-app:2.0" -f ./Dockerfile-alpine . 
docker image ls
```

- Note that while the size of `techproawsdevopsteam/flask-app:1.0` is approximately 625MB, the size of `techproawsdevopsteam/flask-app:2.0` is 60.2MB.

- Run the newly built image as container in detached mode, connect host `port 8080` to container `port 80`, and name container as `welcome`. Then list running containers and connect to EC2 instance from the browser to show the Flask app is running.

```bash
docker run -d --name welcome_alpine -p 8080:80 techproawsdevopsteam/flask-app:2.0
docker ps
```

- Stop and remove the container `welcome and welcome_alpine `.

```bash
docker stop welcome && docker rm welcome
docker stop welcome_alpine && docker rm welcome_alpine
```

- Push newly built image to Docker Hub, and show the updated repo on Docker Hub.

```bash
docker push techproawsdevopsteam/flask-app:2.0
```

- We can also tag the same image with different tags.

```bash
docker image tag techproawsdevopsteam/flask-app:2.0 techproawsdevopsteam/flask-app:latest
docker images
```
- Push newly built image to Docker Hub, and show the updated repo on Docker Hub.

```bash
docker push techproawsdevopsteam/flask-app
```

- Delete image with `image id` locally.

```bash
docker image rm 497
```
