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