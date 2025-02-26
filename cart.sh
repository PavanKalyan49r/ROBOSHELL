#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2 ...$R failed $N"
    exit 1
    else
    echo -e "$2 ...$G success $N"
    fi
}

if [ $ID -ne 0 ]
then
echo -e "$R ERROR:: please run this script with root access $N"
exit 1 #you can give other than 0
else
echo "you are root user"
fi # fi  means reverse of if, indicating condtion end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabeling current nodeJS" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabeling current nodeJS" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodeJS"

id roboshop
if [ $? -ne 0 ]
then
useradd roboshop
VALIDATE " roboshop user creation "
else
echo -e " roboshop user already exist $Y skipping $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "downloading cart application" 

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipping cart"

npm install &>> $LOGFILE

VALIDATE $? "installimg dependencies"

#use absolute, because cart.service exists there
cp /home/centos/ROBOSHELL/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart demon reload" 

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enable cart" 

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart"