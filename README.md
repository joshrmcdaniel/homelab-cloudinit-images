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
```


## Running
Create `variables.pkrvars.hcl` in the containing directory with the [example above](#variables-file-example)
``` shell
packer init .
packer validate -var-file=your_vars.pkrvars.hcl .
packer build -var-file=your_vars.pkrvars.hcl .
```

## Further information
See [here](https://developer.hashicorp.com/packer/plugins/builders/vmware/iso#vmware-builder-from-iso) for the official documentation on the `vmware-iso` plugin