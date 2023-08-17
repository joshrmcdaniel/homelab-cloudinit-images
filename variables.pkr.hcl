variable "esxi_host" {
  description = "ESXi Host."
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

variable "datastore" {
  description = "Datastore to output the resulting build to."
  type        = string
}