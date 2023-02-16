# CICD-project-web
using groovy script in jenkins pipeline
![image](https://user-images.githubusercontent.com/119730245/219352557-fa7bfeee-5cd0-4981-b4d0-3297bbf2bd38.png)
# Website launch
![image](https://user-images.githubusercontent.com/119730245/219354380-2ba810e4-d4a5-4339-8234-5cd67a23fc47.png)
# Groovy script
pipeline {
    agent any
    
    stages{
        stage('Git Code check'){
            steps{
                git branch: 'main', url: 'https://github.com/Mahesh8887/kubernatesproject.git' 
            }
        }
        stage('Sending docker file to Ansible server over ssh'){
            steps{
                sshagent(['ansible']) {
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@172.31.45.248'
                    sh "scp /var/lib/jenkins/workspace/CICD-jenkin/* ec2-user@172.31.45.248:/home/ec2-user/"
                }
            }
        }
       stage('Docker Build image'){
            steps{
                sshagent(['ansible']) {
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@172.31.45.248 cd /home/ec2-user/'
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@172.31.45.248 docker build . -t mahesh8887/node:latest'
                }
            }
        }
        stage('Push docker image to docker hub'){
            steps{
                sshagent(['ansible']) {
                    withCredentials([string(credentialsId: 'dockerhub', variable: 'dockerhub')]) {
        	        sh "docker login -u mahesh8887 -p ${env.dockerhub}"
                    sh 'docker push mahesh8887/node:latest'
                }
            }
        } 
        }
        stage('Deploy'){
            steps{
                sshagent(['ansible']) {
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@172.31.45.248 cd /home/ec2-user/'
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@172.31.45.248 docker run -d -p 8000:80 mahesh8887/node:latest'
                }
            }

        }         
    }
}
#### Docker File ####

FROM amazonlinux:latest

# Install dependencies
RUN yum update -y && \
    yum install -y httpd && \
    yum search wget && \
    yum install wget -y && \
    yum install unzip -y

# change directory
RUN cd /var/www/html

# download webfiles
RUN wget https://github.com/azeezsalu/techmax/archive/refs/heads/main.zip

# unzip folder
RUN unzip main.zip

# copy files into html directory
RUN cp -r techmax-main/* /var/www/html/

# remove unwanted folder
RUN rm -rf techmax-main main.zip

# exposes port 80 on the container
EXPOSE 80 

# set the default application that will start when the container start
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]


