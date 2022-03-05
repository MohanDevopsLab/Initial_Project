#! /bin/bash

#Terraform runs the below commands with root. Hence no need to specify sudo in cmds

# Install Java
yum install java-1.8.0-openjdk.x86_64 -y

# Download and Install Jenkins
yum update –y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
#wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
#rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y

# Start Jenkins
systemctl start jenkins

# Enable Jenkins with systemctl
systemctl enable jenkins

# Install Git SCM
yum install git -y

# Make sure Jenkins comes up/on when reboot
chkconfig jenkins on