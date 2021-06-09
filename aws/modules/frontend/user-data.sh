# Substitute $search with $replace
SEARCH="apigateway_url"
REPLACE="${apigw_url}/counter-app-resource"

sudo apt-get update -y

sudo apt-get install nginx -y


mv /usr/share/nginx/html/index.html /usr/share/nginx/html/old-index.html

sudo git clone https://github.com/franckies/multicloud-terraform.git

mv multicloud-terraform/aws/modules/frontend/frontend-app /usr/share/nginx/html

sed -i "s/$SEARCH/$REPLACE/gi" /usr/share/nginx/html/index.html

sudo service nginx start

