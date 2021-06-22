variable "resource_group" {
  type = map(any)
  default = {
    name   = "cloud-semeraro-tesina"
    region = "westeurope"
  }
  description = "Resource group name and region."
}
variable "vnet_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The CIDR of the VPC."
}
variable "private_subnet" {
  type        = list(string)
  default     = ["192.168.2.0/24"]
  description = "Private subnet CIDR where the front end layer will be deployed."
}
variable "intra_subnet" {
  type        = list(string)
  default     = ["192.168.1.0/24"]
  description = "Intra subnet CIDR where the lambda function will be deployed."
}
variable "public_subnet" {
  type        = list(string)
  default     = ["192.168.0.0/24"]
  description = "Public subnet CIDR where the bastion and application load balancer will be deployed."
}
variable "prefix_name" {
  type        = string
  default     = "counter-app"
  description = "Prefix name for application layer."
}