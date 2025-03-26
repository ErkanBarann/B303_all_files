# Hands-on Docker-01 : Installing Docker on Ubuntu 24.04 AWS EC2 Instance

Purpose of the this hands-on training is to teach the students how to install Docker on on Ubuntu 24.04 EC2 instance.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- install Docker on Ubuntu 24.04 EC2 instance

- configure a Cloudformation template for creating a Docker machine

- list the help about the Docker commands.

- run a Docker container on EC2 instance.

- list the running and stopped Docker containers.

- explain the properties of Docker containers.

- start, stop, and remove Docker containers.

## Outline

- Part 1 - Launch Ubuntu 24.04 EC2 Instance and Connect with SSH

- Part 2 - Install Docker on Ubuntu 24.04 EC2 Instance

- Part 3 - Configure a Cloudformation Template for a Docker machine

- Part 4 - Basic Container Commands of Docker

## Part 1 - Launch Ubuntu 24.04 EC2 Instance and Connect with SSH

- Launch an EC2 instance using the Ubuntu 24.04 AMI with security group allowing SSH connections.

- Connect to your instance with SSH.

```bash
ssh -i .ssh/call-training.pem ubuntu@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

## Part 2 - Install Docker on Ubuntu 24.04 EC2 Instance

- Set up Docker's apt repository.

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

- Install the Docker packages.

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

- Start docker service.

- Init System: Init (short for initialization) is the first process started during booting of the computer system. It is a daemon process that continues running until the system is shut down. It also controls services at the background. For starting docker service, init system should be informed.

```bash
sudo systemctl start docker
```

- Enable docker service so that docker service can restart automatically after reboots.

```bash
sudo systemctl enable docker
```

- Check if the docker service is up and running.

```bash
sudo systemctl status docker
docker version
sudo docker version
```

- Create the docker group.
```bash
sudo groupadd docker
```

- Add your user to the docker group.
```bash
sudo usermod -aG docker $USER
```

- You can also run the following command to activate the changes to groups:
```bash
newgrp docker
```

- Check the docker version without `sudo`.

```bash
docker version

Client:
 Version:           20.10.17
 API version:       1.41
 Go version:        go1.18.6
 Git commit:        100c701
 Built:             Wed Sep 28 23:10:17 2022
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.17
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.18.6
  Git commit:       a89b842
  Built:            Wed Sep 28 23:10:55 2022
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.6
  GitCommit:        10c12954828e7c7c9b6e0ea9b0c02b01407d3ae1
 runc:
  Version:          1.1.3
  GitCommit:        1e7bb5b773162b57333d57f612fd72e3f8612d94
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

- Check the docker info without `sudo`.

```bash
docker info

Client:
 Context:    default
 Debug Mode: false

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 20.10.17
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 io.containerd.runtime.v1.linux runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 10c12954828e7c7c9b6e0ea9b0c02b01407d3ae1
 runc version: 1e7bb5b773162b57333d57f612fd72e3f8612d94
 init version: de40ad0
 Security Options:
  seccomp
   Profile: default
 Kernel Version: 5.10.144-127.601.amzn2.x86_64
 Operating System: Amazon Linux 2
 OSType: linux
 Architecture: x86_64
 CPUs: 1
 Total Memory: 964.8MiB
 Name: ip-172-31-29-80.ec2.internal
 ID: LIYF:SOW7:SB35:3WNG:WB76:C356:2KLZ:G4J2:KLAD:CZ7K:P2NG:DUOW
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: fals
```

## Part 3 - Configure a Cloudformation Template for a Docker machine

- Write and configure a Cloudformation Template to have a Docker machine ready on Ubuntu 24.04 EC2 Instance with security group allowing SSH connections from anywhere.

```yaml
AWSTemplateFormatVersion: 2010-09-09

Description: >
  This Cloudformation Template creates a Docker machine on EC2 Instance.
  Docker Machine will run on Ubuntu 24.04 (ami-084568db4383264d4) EC2 Instance with
  custom security group allowing SSH connections from anywhere on port 22.

Parameters:
  KeyPairName:
    Description: Enter the name of your Key Pair for SSH connections.
    Type: String
    Default: techpro

Resources:
  DockerMachineSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable SSH for Docker Machine
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
  DockerMachine:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-084568db4383264d4
      InstanceType: t2.micro
      KeyName: !Ref KeyPairName
      SecurityGroupIds:
        - !GetAtt DockerMachineSecurityGroup.GroupId
      Tags:
        -
          Key: Name
          Value: !Sub Docker Machine of ${AWS::StackName}
      UserData:
        Fn::Base64: |
          #! /bin/bash
          curl -fsSL https://get.docker.com -o get-docker.sh
          sh get-docker.sh
          sudo groupadd docker
          sudo usermod -aG docker ubuntu
          newgrp docker
Outputs:
  WebsiteURL:
    Description: Docker Machine DNS Name
    Value: !Sub
      - ${PublicAddress}
      - PublicAddress: !GetAtt DockerMachine.PublicDnsName
```
## Part 4 - Basic Container Commands of Docker

- Check if the docker service is up and running.
```bash
sudo systemctl status docker
docker --version
```
- Run either `docker` or `docker help` to see the help docs about docker commands.

```bash
docker help 
```

- Run `docker COMMAND --help` to see more information about specific command.

```bash
docker run --help | less
```
```bash
docker run hello-world
```
- Download and run `ubuntu` os with interactive shell open.

```bash
docker run -i -t ubuntu bash
```

- Display the os name on the container for the current user.

```bash
ls
cat /etc/os-release
```

- Display the shell name on the container for the current user.

```bash
echo $0
```

- Update and upgrade os packages on `ubuntu` container.

```bash
apt-get update && apt-get upgrade -y
```

- Show that `ubuntu` container is like any other Ubuntu system but limited.

  - Go to the home folder and create a file named as `myfile.txt`

    ```bash
    cd ~ && touch myfile.txt && ls
    pwd
    exit
    ```
```bash
docker run -it ubuntu bash
pwd
cd
whoami
ls 
pwd
```

```bash
exit
```
Docker container properties

- Show the list of all containers available on Docker machine and explain container properties.

```bash
docker ps --help
docker ps -a
```

or

```bash
docker container ls -a
```
 Docker start

```bash
docker start --help
docker start 2270421f0032
docker ps
docker start 342
docker ps -a
docker start romantic_colden
```
- Run the second `ubuntu` os with interactive shell open and name container as `techpro` and show that this `ubuntu` container is different from the previous one.

```bash
docker run -it --name techpro ubuntu bash
exit
docker ps -a
```

- Show the list of all containers again and explain the second `ubuntu` containers' properties and how the names of containers are given.

```bash
docker container ls -a
```

- Restart the first container by its `ID`.

```bash
docker start 4e6
```

- Show only running containers and explain the status.

```bash
docker container ls
```

- Stop the first container by its `ID` and show it is stopped.

```bash
docker stop 4e6 && docker container ls -a
```

- Restart the `techpro` container by its name and list only running containers.

```bash
docker start techpro && docker container ls
```

- Connect to the interactive shell of running `techpro` container and `exit` afterwards.

```bash
docker images
docker image ls
```

```bash
docker run nginx
ctrl c
docker ps -a
docker  rm ca73691

docker run -d nginx
docker ps
docker rm -f 38
docker run -d -p 80:80 nginx
docker exec 1db32 ls pwd date
docker exec -it 1db32 bash
exit
```

- Show that  container has stopped by listing all containers.

```bash
docker run -d -p 81:80 httpd
docker container ls -a
```

- Restart the first container by its `ID` again and exec -it to it to show that the file we have created is still there under the home folder, and exit afterwards.

```bash
docker start 4e6 && docker exec -it 4e6 bash
exit
```

- Show that we can get more information about `techpro` container by using `docker inspect` command and explain the properties.

```bash
docker inspect techpro | less
wq
```

- Delete the first container using its `ID`.

```bash
docker rm 4e6
```

- Delete the second container using its name.

```bash
docker rm 124
docker container rm -f 6354
docker container prune 
docker container rm -f $(docker ps -aq)
```

- Show that both of containers are not listed anymore.

```bash
docker container ls -a
```
