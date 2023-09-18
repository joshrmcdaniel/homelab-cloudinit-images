provider "vsphere" {
  user                 = "myuser"
  password             = "mypassword"
  vsphere_server       = "my.exsi.host"
  allow_unverified_ssl = true
}
