# Hands-on Jenkins-04 : Agent Node Configuration and DSL Job

Purpose of the this hands-on training is to learn how to configure an agent node to Jenkins Server. 

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- configure a agent node

- run jobs on agent node.

- create job DSL

## Outline

- Part 1 - Agent Node Configuration

- Part 2 - Free Style Project on Agent Node

- Part 3 - Pipeline Project on Agent Node

- Part 4 - Jenkins Job DSL

## Part 1 - Agent Node Configuration

- Launch an instance on Amazon Linux 2023 AMI with security group allowing SSH (port 22) as agent node.(instance type:t2 micro)

- Connect to your instance with SSH.

- Install Java
  
```bash
sudo dnf update -y
sudo dnf install java-21-amazon-corretto -y
```

- Install Git
  
```bash
sudo dnf install git -y
```
- Go to the Jenkins Dashboard: 
  - Install  `Command Agent Launcher Plugin` on Jenkins controller.

  - Follow `Manage Jenkins` -> `Plugins` --> `Available plugins` path and install the plugins (install without restart):

    -  `Command Agent Launcher`

- **Configure ssh connection between controller and agent nodes.**

- **Go to the Jenkins Controller server:** 
  - Switch to "jenkins" user.

```bash
sudo su - jenkins -s /bin/bash
```

  - Generate a public and private key with keygen.

```bash
ssh-keygen
```
  - Press enter for every question to continue with default options. 

  - Check ".ssh" folder and see public(id_rsa.pub) and private keys(id_rsa). 

```bash
cd .ssh
ls
```
  - We need to copy public key to agent node.

```bash
cat id_rsa.pub
```
  - Select and copy all the codes in id_rsa.pub.

- **Go to the /root/.ssh folder on the agent node instance**

```bash
sudo su
cd /root/.ssh
vim authorized_keys
```

- Open the "authorized_keys" file with an editor and paste the code that you copied from public key(id_rsa.pub). Save "authorized_keys" file.

- Get the agent node ip:

```bash
ifconfig
```
- Copy ip number.

- Go to the Jenkins Controller server and test ssh connection.

```bash
ssh root@<agent-node-ip-number>
exit
```

- **The second one is to copy agent file from Jenkins server to agent node.**

- Go to the "/root" folder on the agent node instance. Create a folder under "/root" and name it as "bin". Get agent file from Jenkins Controller server.

```bash
cd /root
mkdir bin
cd bin
wget http://<jenkins_controller_ip>:8080/jnlpJars/agent.jar
ls
```

Command Agent Launcher

- Go to Jenkins dashboard, click on "Manage Jenkins" from left hand menu.

- Select `System Configuration-->Nodes`

- Click on "New Node".

- Enter `AgentNode-1` in "Node name" field and select `Permanent Agent`.

- Click `Create` button.

- Enter `This is a linux agent node for jenkins` in the description field.

- "Number of executors" is the maximum number of concurrent builds that Jenkins may perform on this node. Enter `2` in this field.

- An agent needs to have a directory dedicated to Jenkins. Specify the path to this directory on the agent. Enter `/usr/jenkins` in the "Remote root directory" field.

- Enter `Linux` in the "Labels" field.

- Select `Launch agent via execution of command on the controller` from dropdown menu in the "Launch method" field.

- Enter `ssh -i /var/lib/jenkins/.ssh/id_rsa root@<agent_ip> java -jar -Djava.io.tmpdir=/mnt /root/bin/agent.jar` in the "Launch command" field.

- Select `Keep this agent online as much as possible` from dropdown menu in the "Availability" field.

- Click `Save`.

- Check the console logs in case of failure to launch agent node. If there is a approvement issue go to `Manage Jenkins`,  select the `In-process Script Approval`, `approve` the script.

- Go to Jenkins dashboard. Check controller and agent nodes on the left hand menu. 

## Part 2 - Free Style Project on Agent Node

- Open your Jenkins dashboard and click on `New Item` to create a new job item.

- Enter `agent-job` then select `free style project` and click `OK`.

  - Enter `My first simple free style job on agent node` in the description field.

  - Find the `General` section, click "Restrict where this project can be run" and enter `Linux` for "Label Expression"

  - Go to `Build Steps` section and choose "Execute Shell" step from `Add build step` dropdown menu.

  - Write down just `echo "Hello World, This is a job for agent node"` to execute shell command, in text area shown.

  - Click `apply` and `save`  buttons.

- Go to `agent job`.

- Select `Build Now` on the left hand menu

- Check "Build Queue" section to see build process running on agent node on the left hand menu. 

## Part 3 - Pipeline Project on Agent Node

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `simple-pipeline-on-agent-node` then select `Pipeline` and click `OK`.

- Enter `My first simple pipeline on agent node` in the description field.

- Go to the `Pipeline` section, enter following script, then click `apply` and `save`.

```text
pipeline {
    agent { label 'Linux' }
    stages {
        stage('build') {
            steps {
                echo "Welcome to TechPro Education IT Bootcamp!"
                sh 'echo second step'
                sh 'echo another step'
                sh 'sleep 30'
                sh '''
                echo 'working on'
                echo 'agent node'
                '''
          
            }
        }
    }
}
```

- Go to the project page and click `Build Now`.

- Explain the built results.

- Explain the pipeline script.


## Part 4 - Jenkins Job DSL

- Go to the Jenkins Dashboard: 
  - Install  `Job DSL` on Jenkins controller.

  - Follow `Manage Jenkins` -> `Plugins` --> `Available plugins` path and install the plugins (install without restart):

    -  `Job DSL`

- Go to the dashboard and create a `Seed Job` in form of `Free Style Project`. To do so;

- Click on `New Item`

  - Enter name as `Seed-Job`

  - Select `Freestyle project`

  - Click `OK`

- Inside `Source Code Management` tab

  - Select `Git`
  
  - Select the path to download the DSL file, so for `Repository URL`, enter `https://github.com/techpro-aws-devops/Jenkins-DSL-Job-Example.git` and `Branch Specifier` `master --> main`

- Inside `Build Steps` tab

  - From `Add build step`, select the `Process Job DSLs`.

  - for `Look on Filesystem -->> DSL Scripts`, enter `jobDSL.groovy`

- Click `apply` and `save`  buttons.
  
- Now click the  `Build Now` option, it will fail. Check the console log for the fail reason.

- Go to `Manage Jenkins` ,  select the `In-process Script Approval`, `approve` the script.
  
- Go to the job and click the  `Build Now` again.

- Observe that DSL Job created.

- Go to the Jenkins dashboard and view the jobs. (`run-python-script-job-DSL`)


