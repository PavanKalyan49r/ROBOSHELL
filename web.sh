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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "INSTALLING NGINX SERVER"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "ENABLING NGINX"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "STARTING NGINX SERVER"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "REMOVING DEFAULT CONTENT"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "DOWNLOADING WEB CONTENT "

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "CHANGING  DIRECTORY"

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE $? "UNZIPPING WEB CONTENT"

cp /home/centos/ROBOSHELL/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "COPIED ROBOSHOP REVERSE PROXY CONFIGURATION"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "RESTARTING NGINX"