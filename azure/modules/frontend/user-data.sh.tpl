#!/bin/sh
cd /home/azureuser 

# Install httpd
sudo apt-get update -y 
sudo apt-get install apache2 -y 
sudo apt-get install git -y

# Install frontend app
echo ${apiname} > text.txt
git clone https://github.com/franckies/multicloud-terraform.git
sudo chmod go+rw /var/www/html
sudo cp /home/azureuser/multicloud-terraform/azure/modules/frontend/frontend-app/* /var/www/html
#sed -i "s/$SEARCH/$REPLACE/gi" /var/www/html/index.html
sudo chmod 644 /var/www/html/api_url.js
sudo echo 'var api_url = "${apiname}";' > /var/www/html/api_url.js

# Restart httpd
sudo systemctl start apache2
