resource "vsphere_virtual_machine" "example" {
  name               = "example"
  resource_pool_id   = data.vsphere_resource_pool.this.id
  host_system_id     = data.vsphere_host.this.id
  datastore_id       = data.vsphere_datastore.this.id
  num_cpus           = 2
  memory             = 4096
  memory_reservation = 4096
  guest_id           = "debian11_64Guest"

  network_interface {
    network_id   = data.vsphere_network.this.id
    adapter_type = "vmxnet3"
  }
  disk {
    label        = "disk0"
    attach       = true
    path         = vsphere_file.debian_cloudinit.destination_file
    datastore_id = data.vsphere_datastore.this.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(file("./provision/metadata.yaml"))
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(file("./provision/userdata.yaml"))
    "guestinfo.userdata.encoding" = "gzip+base64"
    # I don't use it.
    # "guestinfo.vendordata"          = base64gzip(file("./provision/vendordata.yaml"))
    # "guestinfo.vendordata.encoding" = "gzip+base64"
  }

  lifecycle {
    replace_triggered_by = [ vsphere_file.debian_cloudinit ]
  }
}

resource "vsphere_file" "debian_cloudinit" {
  source_datacenter  = data.vsphere_datacenter.this.name
  datacenter         = data.vsphere_datacenter.this.name
  source_datastore   = data.vsphere_datastore.this.name
  datastore          = data.vsphere_datastore.this.name
  source_file        = "base/debian12/disk.vmdk"
  destination_file   = "path/to/dest/vm/disk.vmdk"
  create_directories = true # Change to false if path/to/dest/vm exists
}