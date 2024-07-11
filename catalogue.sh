#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.pavanaws.online

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

VALIDATE $? "DISABLED NODEJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "ENABLED NODEJS18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "INSTALL NODEJS"

id roboshop
if [ $? -ne 0 ]
then
useradd roboshop
VALIDATE $? " roboshop user creation "
else
echo -e " roboshop user already exist $Y skipping $N"
fi

mkdir -p /app

VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? " DOWNLOAD CATALOGUE APPLICATION CODE"

cd /app

unzip -o /tmp/catalogue.zip

VALIDATE $? "UNZIPPING CATALOGUE"

npm install &>> $LOGFILE

VALIDATE $? "INSTALLING DEPENDENCIES"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "COPYING CATALOGUE SERVICE FILE"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "CATALOGUE DAEMON RELOAD"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "ENABLE CATALOGUE"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "START CATALOGUE"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "COPYING MONGO REPO"

dnf install mongodb-org-shell -y &>> $LOGFILE 

VALIDATE $? "INSTALLING MONGODB CLIENT"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "LOADING CATALOGUE DATA INTO  MONGODB"