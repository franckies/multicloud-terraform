# multicloud-terraform
Implementation of a 3-tier web application infrastructure with terraform on multiple cloud providers.
# Aws
## Get started
Configure your profile settings with _awscli_ inserting your _access key ID_ and _secret access key_:
```
aws configure
```
Then just run the following commands to have your infrastructure up and configured.
```
cd ./aws
terraform init
terraform plan
terraform apply
```

# Azure
## Get started
Use the _azcli_ to login and then set your subscription:
```
az login
az account set --subscription="your_subscription_id"
```
Then just run the following commands to have your infrastructure up and configured.
_Beware that the api management service can take up to 1h to be deployed!_
```
cd ./azure
terraform init
terraform plan
terraform apply
```
