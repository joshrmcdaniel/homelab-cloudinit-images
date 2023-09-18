# homelab-cloudinit-images
Packer builds to create golden images with `open-vm-tools` and `cloud-init` for ESXi. Resulting builds are stored on the ESXi server.

Currently builds Debian 12 and Rocky Linux 9

**Each build must be consecutive, with trivial changes you could parallel build (this relating to the network setup).**

## Requirements
- ESXi (tested on 7U3n)
- Packer
- Ingress rules on the running machine for the kickstart/preseed file
- Open adapter within ESXi to associate the build with

## Variables File Example
```hcl
esxi_host     = "my.exsi.host"
esxi_user     = "myuser"
esxi_password = "mypassword"
datastore     = "mydatastore"
network_name  = "packer"
esxi_insecure = true
disk_size     = 20
```

## Running
- Create `variables.pkrvars.hcl` in the containing directory with the [example above](#variables-file-example)
- Enable `TSM-SSH` on the ESXi instance and use credentials with permissions for SSH

Run the following:
``` shell
packer init .
packer validate -var-file=variables.pkrvars.hcl .
packer build -var-file=variables.pkrvars.hcl -parallel-builds=1 .
```


### Running on WSL2
This will not work without a couple modifications. The port from the host machine will need to be bridge from Windows to WSL. This can be achieved with the following commands
- `netsh interface portproxy add v4tov4 listenport=8312 listenaddress=0.0.0.0 connectport=8312 connectaddress=<wsl2 addr>`
- `New-NetFirewallRule -DisplayName "Packer WSL2 Port Bridge" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8312`

The port choice doesn't matter, just ensure it matches with the port configuration below

Add the following variables to `variables.pkrvars.hcl`
```hcl
http_host     = "<host ip>" # NOT THE WSL2 IP
http_port_min = 8312
http_port_max = 8312
```
Run Packer, and it will work as expected.

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
If using terraform to manage ESXi resources,s ee [`example/`](example/) folder for an example terraform setup. This assumes the `remote_output_directory` (`base/`) is not changed

### `metadata.yaml`
```yaml
instance-id: 555
hostname: vm
local-hostname: vm.example.com
cloud_name: vmware
platform: vmware
```

### `vendordata.yaml`
I don't know, I don't use it. [See here](https://cloudinit.readthedocs.io/en/23.2.2/explanation/vendordata.html) for info

### `userdata.yaml`
```yaml
#cloud-config
manage_etc_hosts: localhost

users:
  - default
  - name: jeff
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: [ sudo, wheel ]
    lock_passwd: true
    shell: /bin/bash
    ssh_authorized_keys:
    - pubkey1
    - pubkey2

runcmd:
  - echo "Hi"

packages:
  - make
  - gcc
  - xorg
```

**Unless you know what you're doing, `#cloud-config` needs to be on the first line**


## Further information
See [here](https://developer.hashicorp.com/packer/plugins/builders/vmware/iso#vmware-builder-from-iso) for the official documentation on the `vmware-iso` plugin

See [here](https://cloudinit.readthedocs.io/en/23.2.2) for cloud-init docs

See [here](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs) for vSphere provider documentation