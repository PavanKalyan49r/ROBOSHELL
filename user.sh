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

VALIDATE $? "DISABLING NODEJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "ENABLING NODEJS 18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "INSATLLING NODEJS"

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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "DOWNLOADING USER CONTENT"

cd /app &>> $LOGFILE

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "UNZIPPING USER CONTENT"

npm install &>> $LOGFILE

VALIDATE $? "INSTALLING DEPENDENCIES"

cp /home/centos/ROBOSHELL/user.service /etc/systemd/system/user.service

VALIDATE $? "COPYING USER SERVICE FILE "

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "DAEMON RELOAD"

systemctl enable user &>> $LOGFILE

VALIDATE $? "ENABLING USER"

systemctl start user &>> $LOGFILE

VALIDATE $? "STARTING USER"

cp /home/centos/ROBOSHELL/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "COPYING MONGODB REPO"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "INSTALLING MONGODB"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "LOADING USER DATA INTO MONGODB"