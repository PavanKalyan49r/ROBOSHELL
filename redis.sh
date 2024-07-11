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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "INSTALLING REMI RELEASE"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "ENABLING REDIS"

dnf install redis -y &>> $LOGFILE

VALIDATE $? "INSTALLING REDIS"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE

VALIDATE $? "ALLOWING REMOTE CONNECTIONS"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "ENABLING REDIS"

systemctl start redis &>> $LOGFILE

VALIDATE $? "STARTING REDIS"