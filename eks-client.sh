#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG="/home/ec2-user/eks-client-install/eks-client-install.log"
mkdir -p /home/ec2-user/eks-client-install
cd /home/ec2-user/eks-client-install

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo  -e "$R You are not the root user, you don't have permission to run this script. $N"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

# -------------------------------
# STEP 1: Install Docker on Amazon Linux 2023
# -------------------------------
echo -e "$Y Installing Docker... $N"
dnf install docker -y &>> $LOG
VALIDATE $? "Installed Docker"

systemctl enable docker &>> $LOG
systemctl start docker &>> $LOG
VALIDATE $? "Started Docker service"

usermod -aG docker ec2-user
echo -e "$G Docker Installed and Configured $N"

# -------------------------------
# STEP 2: Install AWS CLI v2
# -------------------------------
echo -e "$Y Installing AWS CLI... $N"
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &>> $LOG
VALIDATE $? "Downloaded AWS CLI V2"

unzip -o awscliv2.zip &>> $LOG
VALIDATE $? "Unzipped AWS CLI V2"

./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update &>> $LOG
VALIDATE $? "Installed AWS CLI V2"

# -------------------------------
# STEP 3: Install eksctl
# -------------------------------
echo -e "$Y Installing eksctl... $N"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
VALIDATE $? "Downloaded eksctl"

chmod +x /tmp/eksctl
VALIDATE $? "Set executable permission on eksctl"

mv /tmp/eksctl /usr/local/bin
VALIDATE $? "Moved eksctl to /usr/local/bin"

# -------------------------------
# STEP 4: Install kubectl
# -------------------------------
echo -e "$Y Installing kubectl... $N"
curl -s -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.10/2023-01-30/bin/linux/amd64/kubectl
VALIDATE $? "Downloaded kubectl"

chmod +x kubectl
VALIDATE $? "Set executable permission on kubectl"

mv kubectl /usr/local/bin/kubectl
VALIDATE $? "Moved kubectl to /usr/local/bin"

echo -e "$G All tools installed successfully! Please reboot or re-login to apply docker group changes. $N"
