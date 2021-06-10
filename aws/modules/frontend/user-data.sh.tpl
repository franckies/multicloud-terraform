#!/bin/bash -xe
REPLACE='${REPLACE}'

# Install httpd
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
cd /home/ec2-user

# Install front end app
sudo yum install -y git 
git clone https://github.com/franckies/multicloud-terraform.git
sudo chmod go+rw /var/www/html
sudo cp /home/ec2-user/multicloud-terraform/aws/modules/frontend/frontend-app/* /var/www/html
#sed -i "s/$SEARCH/$REPLACE/gi" /var/www/html/index.html
sudo echo 'var api_url = "${REPLACE}/counter-app-resource";' > /var/www/html/api_url.js

# Restart httpd
sudo chkconfig httpd on
sudo service httpd start
sudo service httpd restart