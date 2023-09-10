# homelab-cloudinit-images
Packer builds to create provisioned VMs with `open-vm-tools` and `cloud-init` configured. Resulting buils stored on the ESXi server.

Currently builds Debian 12 and Rocky Linux 9

## Requirements
- ESXi (tested on 7U3n)
- Packer
- Ingress rules on the running machine for the kickstart/preseed file

## Variables File Example
``` hcl
esxi_host     = "my.exsi.host"
esxi_user     = "myuser"
esxi_password = "mypassword"
datastore     = "mydatastore"
network_name  = "packer"
esxi_insecure = true
disk_size     = 20
```


## Running
Create `variables.pkrvars.hcl` in the containing directory with the [example above](#variables-file-example)
``` shell
packer init .
packer validate -var-file=your_vars.pkrvars.hcl .
packer build -var-file=your_vars.pkrvars.hcl .
```

## Using in deployments
The resulting build produces a single disk. If you prefer not re-running the build on every vm, copy the build to elsewhere for storage.
The metadata, userdata, and vendordata yml is stored in the vmx config under the following keys:
- `guestinfo.metadata`
- `guestinfo.userdata`
- `guestinfo.vendordata`

The encoding can be gzip+base64, or base64. That information is stored under the following keys:
- `guestinfo.metadata.encoding`
- `guestinfo.userdata.encoding`
- `guestinfo.vendordata.encoding`

## Example
If using terraform to manage ESXi resources, here is an example `vsphere_virtual_machine` resource to use the provided packer build. The example also uses a `vsphere_file` resource to automatically copy the file to the destination provided.

### `vm.tf`
```hcl2
resource "vsphere_virtual_machine" "example" {
  name               = "example"
  resource_pool_id   = data.vsphere_resource_pool.this.id
  host_system_id     = data.vsphere_host.this.id
  datastore_id       = data.vsphere_datastore.this.id
  num_cpus           = 2
  memory             = 4096
  memory_reservation = 4096
  guest_id           = "debian11_64Guest"
  memory_limit       = -1

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
    "guestinfo.metadata"          = base64gzip(file("path/to/metadata.yaml"))
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(file("path/to/userdata.yaml"))
    "guestinfo.userdata.encoding" = "gzip+base64"
    "guestinfo.vendordata"          = base64gzip(file("path/to/userdata.yaml"))
    "guestinfo.vendordata.encoding" = "gzip+base64"
  }
}

resource "vsphere_file" "debian_cloudinit" {
  source_datacenter  = data.vsphere_datacenter.this.name
  datacenter         = data.vsphere_datacenter.this.name
  source_datastore   = data.vsphere_datastore.this.name
  datastore          = data.vsphere_datastore.this.name
  source_file        = "path/to/output/disk.vmdk"
  destination_file   = "path/to/vm/disk.vmdk"
  create_directories = true
}

```

### `metadata.yaml`
```yaml
instance-id: example-instance
hostname: example
local-hostname: example
cloud_name: vmware
platform: vmware
```

### `userdata.yaml`
```yaml
#cloud-config
manage_etc_hosts: localhost
# Add user and give sudo access
users:
  - default
  - name: jeff
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: [ sudo, wheel ]
    lock_passwd: true
    shell: /bin/bash
    ssh_authorized_keys:
    - key1
    - key2

runcmd:
  - echo "Hi"

packages:
  - make
  - gcc
  - xorg
```
Unless you know what you're doing, `#cloud-init` **needs to be** on the first line 

## Further information
See [here](https://developer.hashicorp.com/packer/plugins/builders/vmware/iso#vmware-builder-from-iso) for the official documentation on the `vmware-iso` plugin