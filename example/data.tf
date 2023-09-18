data "vsphere_datacenter" "this" {
  name = "ha-datacenter"
}

data "vsphere_host" "this" {
  name          = "your.exsi.host"
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore" "this" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  name          = "${vsphere_host_port_group.pg.name}"
  datacenter_id = data.vsphere_datacenter.this.id
  depends_on    = [vsphere_host_port_group.pg]
}

data "vsphere_resource_pool" "this" {}