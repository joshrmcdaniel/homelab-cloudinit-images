variable "esxi_host" {
  description = "FQDN of the ESXi Host."
  type        = string
}

variable "esxi_user" {
  description = "User to authenticate to the ESXi host."
  type        = string
}

variable "esxi_password" {
  description = "Password of the authenticating user to ESXi."
  type        = string
}

variable "esxi_insecure" {
  description = "Skip TLS verification on the ESXi host."
  type        = bool
  default     = true
}

variable "datastore" {
  description = "Datastore to output the resulting build to."
  type        = string
}

variable "network" {
  description = "Network type within ESXi"
  type        = string
  default     = "bridge"
}

variable "network_name" {
  description = "Name of network to use"
  type        = string
}