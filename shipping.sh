#!/bin/bash

ID = $(id -u)
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

dnf install maven -y &>> $LOGFILE 

VALIDATE $? "INSTALLING MAVEN"

id roboshop
if [ ID -ne 0]
then
useradd roboshop
VALIDATE $? " roboshop user creation "
else
echo -e " roboshop user already exist $Y skipping $N"
fi

mkdir -p /app

VALIDATE $? "CREATING APP DIRECTORY"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "DOWNLOADING SHIPPING CONTENT"

cd /app

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "UNZIPPING CONTENT "

mvn clean package &>> $LOGFILE

VALIDATE $? "INSTALLING MAVEN PACKAGE"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "MOVING JAR FILE"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "CONFIGURING SHIPPING SERVICE"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "DAEMON RELOADING"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "ENABLING SHIPPING"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "STARTING SHIPPING"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "INSTALLING MYSQL"

mysql -h mysql.pavanawd.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "SETTING MYSQL ROOT PASSWORD"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "RESTARTING SHIPPING"