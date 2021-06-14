cd /home/azureuser 
echo "aaaa" > test.txt 
sudo apt-get update -y 
sudo apt-get install apache2 -y 
sudo apt-get install git
git clone https://github.com/franckies/multicloud-terraform.git
sudo chmod go+rw /var/www/html
sudo cp /home/azureuser/multicloud-terraform/aws/modules/frontend/frontend-app/* /var/www/html
#sed -i "s/$SEARCH/$REPLACE/gi" /var/www/html/index.html
sudo echo 'var api_url = "${REPLACE}/counter-app-resource";' > /var/www/html/api_url.js
sudo systemctl start apache2
