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


dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "DISABLING MYSQL"

cp /home/centos/ROBOSHELL/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "COPYING MYSQL REPO"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "INSTALLING MYSQL"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "ENABLING MYSQL"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "STARTING MYSQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "SETTING MYSQL ROOT PASSWORD"