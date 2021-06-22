variable "azure_api_url" {
  type        = string
  description = "Endpoint of azure api management for multicloud infrastructure."
  default     = ""
}

variable "prefix_name" {
  type        = string
  default     = "counter-app"
  description = "Prefix name for resources."
}
variable "http_port" {
  type        = number
  default     = 80
  description = "The http port."
}

variable "https_port" {
  type        = number
  default     = 443
  description = "The http port."
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "The ssh port."
}

variable "stage_name" {
  type        = string
  default     = "dev"
  description = "The stage name of the endpoint."
}

variable "ami" {
  type        = string
  default     = "ami-038d7b856fe7557b3"
  description = "The AMI to build up the VMs, default is ubuntu 16.04."
}

variable "vm_instance_type" {
  type        = string
  default     = "t2.small"
  description = "The VMs type within the AutoScalingGroup."
}

variable "asg_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of VMs within the ASG."
}

variable "asg_max_size" {
  type        = number
  default     = 8
  description = "Maximum number of VMs within the ASG."
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The CIDR of the VPC."
}

variable "azs" {
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
  description = "The Availability zones in which the infra will be deployed."
}

variable "private_subnets" {
  type        = list(string)
  default     = ["192.168.2.0/24", "192.168.3.0/24"]
  description = "Private subnets CIDR (one per az), where the front end layer will be deployed."
}

variable "intra_subnets" {
  type        = list(string)
  default     = ["192.168.4.0/24", "192.168.5.0/24"]
  description = "Intra subnets CIDR (one per az), where the lambda function will be deployed."
}

variable "public_subnets" {
  type        = list(string)
  default     = ["192.168.0.0/24", "192.168.1.0/24"]
  description = "Public subnets CIDR (one per az), where the bastion and application load balancer will be deployed."
}