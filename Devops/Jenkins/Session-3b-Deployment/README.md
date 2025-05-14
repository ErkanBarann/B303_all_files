# Hands-on Jenkins-03b : Deploying Application  with Jenkins

Purpose of the this hands-on training is to learn how to deploy applications with Jenkins.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- deploy an application with Jenkins

- automate a Maven project as Pipeline.

## Outline

- Part 1 - Install Java, Maven and Git packages

- Part 2 - Maven Settings

- Part 3 - Installing Plugins

- Part 1 - Building Web Application

- Part 2 - Deploy Application to Staging Environment

- Part 3 - Update the application and deploy to the staging environment

- Part 4 - Deploy application to production environment

- Part 5 - Automate Existing Maven Project as Pipeline with Jenkins

## Part 1 - Install Java, Maven and Git packages

- Connect to the Jenkins Server 
  
- Install the JDK for Amazon Corretto 21
  
```bash
sudo dnf update -y
sudo dnf install java-21-amazon-corretto-devel -y
```

- Install Maven
  
```bash
sudo su
cd /opt
rm -rf maven
wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
tar -zxvf $(ls | grep apache-maven-*-bin.tar.gz)
rm -rf $(ls | grep apache-maven-*-bin.tar.gz)
ln -s $(ls | grep apache-maven*) maven
echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh
echo 'export PATH=${M2_HOME}/bin:${PATH}' >> /etc/profile.d/maven.sh
exit
source /etc/profile.d/maven.sh
```

## Part 2 - Maven Settings

- Open Jenkins GUI on web browser

- Setting System Maven Path for default usage
  
- Go to `Manage Jenkins`
  - Select `System Configuration -->> System`
  - Find `Global properties -->> Environment variables` part,
  - Click `Add`
    - for `Name`, enter `PATH+EXTRA` 
    - for `Value`, enter `/opt/maven/bin`
- Save

- Setting a specific Maven Release in Jenkins for usage
  
- Go to `Manage Jenkins`
  - Select `System Configuration -->> Tools`
  - To the bottom, `Maven installations -->> Add Maven` section
  - Give a name such as `maven-3.9.6`
  - Select `install automatically`
  - `Install from Apache` version `3.9.6`
- Save

## Part 3 - Installing Plugins

- Follow `Manage Jenkins` -> `System Configuration -->> Plugins -->> Available plugins` path and install the plugins (install without restart):

  -  `AnsiColor`
    
  -  `Copy Artifact`

  -  `Deploy to container`

## Part 4 - Building Web Application

- Select `New Item`

- Enter name as `build-web-application`

- Select `Free Style Project`

```yml
- General:
- Description : This job packages the java-tomcat-sample-main app and creates a war file.

- Discard old builds: 
   Strategy:
     Log Rotation:
       Days to keep builds: 5 
       Max#of builds to keep: 3

- Source Code Management:
    Git:
      Repository URL: https://github.com/techpro-aws-devops/java-tomcat-example.git
      Branch Specifier: master-->>main

- It is public repo, no need for `Credentials`.

- Environments: 
   - Delete workspace before build starts
   - Add timestamps to the Console Output

- Build Steps:
    Invoke top-level Maven targets:
      - Maven Version: maven-3.9.6
      - Goals: clean package
  - Advanced -->> POM: pom.xml

- Post-build Actions:
    Archive the artifacts:
      Files to archive: **/*.war 
```

- Finally `Save` the job.

- Click `Build Now` option.

- Observe the Console Output

## Part 5 - Deploy Application

- Select `New Item`

- Enter name as `Deploy-Application`

- Select `Free Style Project`
```yml
- Description : This job deploys the java-tomcat-example app.

- Discard old builds: 
   Strategy:
     Log Rotation:
       Days to keep builds: 5 
       Max#of builds to keep: 3

- Environments: 
   - Delete workspace before build starts
   - Add timestamps to the Console Output

- Build Steps:
  - Copy artifact from another project:
      - Project name: build-web-application
      - Which build: Latest successful build
        - Check: "Stable build only"
  - Artifact to copy: **/*.war

- Post-build Actions:
    Deploy war/ear to a container:
      WAR/EAR files: **/*.war
      Context path: /
      Containers: Tomcat 9.x Remote
      Credentials:
        Add: Jenkins
          - username: tomcat
          - password: tomcat
      Tomcat URL: http://<tomcat server private ip>:8080
```
- Click on `Save`.

- Go to the `Deploy-Application` 

- Click `Build Now`.

- Explain the built results.

- Open the staging server url with port # `8080` and check the results.

## Part 6 - Update the application and deploy

-  Go to the `build-web-application`
   -  Select `Configure`
```yml
- Post-build Actions:
    Add post-build action:
      Build other projects:
        Projects to build: Deploy-Application
        - Trigger only if build is stable

- Triggers:
    Poll SCM: 
      Schedule: * * * * *
  (You will see the warning `Do you really mean "every minute" when you say "* * * * *"? Perhaps you meant "H * * * *" to poll once per hour`)
```
   - `Save` the modified job.

   - At Project `build-web-application`  page, you will see `Downstream Projects` : `Deploy-Application`

- Update the web site content, and commit to the GitHub.

- Go to the  Project `build-web-application` and `Deploy-Application` pages and observe the auto build & deploy process.

- Explain the built results.

- Open the staging server url with port # `8080` and check the results.


## Part 7 - Automate Existing Maven Project as Pipeline with Jenkins

-  Go to the `build-web-application`
   -  Select `Configure`

```yml
- Post-build Actions:
  *** Remove ---> Build other projects
```

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `build-web-application-code-pipeline` then select `Pipeline` and click `OK`.
```yml
- General:
    Description: This pipeline job packages the java-tomcat-example app and deploys

    - Discard old builds: 
       Strategy:
         Log Rotation:
           Days to keep builds: 5 
           Max#of builds to keep: 3

- Pipeline:
    Definition: Pipeline script from SCM
    SCM: Git
      Repositories:
        - Repository URL: https://github.com/techpro-aws-devops/java-tomcat-example.git
        - Branches to build: 
            Branch Specifier: */main

    Script Path: Jenkinsfile
```

- `Save` and `Build Now` and observe the behavior.

```groovy
pipeline {
    agent any
    stages {
        stage('Build Application') {
             steps{
                build job: 'build-web-application'
            }
        }
        stage('Deploy Application'){
            steps{
                build job: 'Deploy-Application'
            }            
        
        
        }
    }
}
```