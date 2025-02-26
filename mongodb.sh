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

cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "COPIED MONGODB REPO"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "installed mangodb"

systemctl enable mongod

VALIDATE $? "ENABLED MONGODB"

systemctl start mongod

VALIDATE $? "MONGODB STARTED"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

VALIDATE $? "REMOTE ACCESS TO MONGODB"

systemctl restart mongod

VALIDATE $? "RESTARTING MONGODB" &>> $LOGFILE