variable "environment_type" {
  default     = "dev"
  description = "Please provide a valid Azure Region name (i.e. eastus or brsouth) to use in this configuration."
}

variable "hub_location" {
  default = "eastus"
}

variable "hub_vnet_address_space" {
  default = "10.0.0.0/24"
}

variable "hub_frontend_snet_address_prefix" {
  default = "10.0.0.0/26"
}

variable "hub_backend_snet_address_prefix" {
  default = "10.0.0.64/26"
}
variable "hub_firewall_snet_address_prefix" {
  default = "10.0.0.128/26"
}


variable "spoke_ref_id" {
  default = 01
}

variable "spoke_location" {
  default = "eastus"
}

variable "spoke_vnet_address_space" {
  default = "10.0.1.0/24"
}

variable "spoke_frontend_snet_address_prefix" {
  default = "10.0.1.0/26"
}

variable "spoke_backend_snet_address_prefix" {
  default = "10.0.1.64/26"
}


