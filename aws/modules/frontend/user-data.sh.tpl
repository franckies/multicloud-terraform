#!/bin/bash
SEARCH="apigateway_url"
REPLACE="${REPLACE}/counter-app-resource"

mv /home/ubuntu
touch test.txt
apt-get update -y

apt-get install nginx -y
apt-get install git -y
apt-get install curl -y

curl -X POST -d '{"operation":"write","id":"1","counter":"0"}' $REPLACE

git clone https://github.com/franckies/multicloud-terraform.git

cp multicloud-terraform/aws/modules/frontend/frontend-app/* /var/www/html

sed -i "s/$SEARCH/$REPLACE/gi" /var/www/html/index.html

service nginx start


sudo amazon-linux-extras install nginx1.12 -y
sudo yum install git -y
git clone https://github.com/franckies/multicloud-terraform.git
sudo service nginx start
sudo mv /home/ec2-user/multicloud-terraform/aws/modules/frontend/frontend-app/* /usr/share/nginx/html