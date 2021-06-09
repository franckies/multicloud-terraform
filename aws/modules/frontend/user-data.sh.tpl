#!/bin/bash
SEARCH='apigateway_url'
REPLACE='${REPLACE}/counter-app-resource'

cd /home/ec2-user
sudo amazon-linux-extras install nginx1.12 -y
sudo yum install git -y
git clone https://github.com/franckies/multicloud-terraform.git
sudo service nginx start
sudo cp /home/ec2-user/multicloud-terraform/aws/modules/frontend/frontend-app/* /usr/share/nginx/html
sed -i "s/$SEARCH/$REPLACE/gi" /var/www/html/index.html