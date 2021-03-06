variable "prefix_name" {
  type        = string
  default     = "counter-app"
  description = "Prefix name for application layer."
}

variable "resource_group" {
  type = map(any)
  default = {
    name   = "cloud-semeraro-tesina"
    region = "westeurope"
  }
  description = "Resource group name and region."
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

variable "connection_string" {
  description = "The cosmos first connection string."
}

variable "intra_subnet" {
  type        = string
  description = "The intra subnet id."
}

variable "aws_api_url" {
  type = string
  description = "The aws api gateway url for db synchronization."
}