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

variable "disk_size" {
  description = "Size of the VMDK in GB."
  type        = number
  default     = 20
}

variable "http_port_min" {
  description = "Minimum port to use for the http server hosting the kickstart/preseed files."
  type        = number
  default     = 8000
}

variable "http_port_max" {
  description = "Minimum port to use for the http server hosting the kickstart/preseed files."
  type        = number
  default     = 9000
}

variable "http_host" {
  description = "IP/URL hosting the kickstart/preseed files."
  type        = string
  default     = "{{ .HTTPIP }}"
}

variable "efi" {
  description = "Use EFI (required for UEFI bios)"
  type        = bool
  default     = false
}


source "vmware-iso" "base" {
  cpus         = 1
  memory       = 2048
  cores        = 2
  version      = 19
  disk_size    = var.disk_size * 1000
  disk_type_id = "thin"
  boot_wait    = var.efi ? "5s" : "10s"

  remote_host         = "${var.esxi_host}"
  remote_port         = 22
  insecure_connection = var.esxi_insecure
  remote_username     = "${var.esxi_user}"
  remote_password     = "${var.esxi_password}"
  remote_type         = "esx5"

  communicator = "ssh"
  ssh_username = "${var.esxi_user}"
  ssh_password = "${var.esxi_password}"
  ssh_host     = "${var.esxi_host}"


  http_port_min    = var.http_port_min
  http_port_max    = var.http_port_max
  remote_datastore = "${var.datastore}"
  shutdown_command = "VM_ID=$(vim-cmd vmsvc/getallvms | awk '/{{ .Name }}/{ print $1 }');vim-cmd vmsvc/power.getstate $VM_ID | grep 'Powered on' && vim-cmd power.off $VM_ID; exit"
  ssh_timeout      = "10m"
  network          = "${var.network}"
  network_name     = "${var.network_name}"
  vmx_data         = var.efi ? { "firmware" = "efi" } : {}

  vnc_over_websocket = true
  skip_export        = true
  skip_compaction    = true
}

build {
  dynamic "source" {
    for_each = local.builds
    labels   = ["vmware-iso.base"]
    content {
      name                    = source.key
      vm_name                 = source.key
      iso_url                 = source.value.iso_url
      iso_checksum            = source.value.iso_checksum
      guest_os_type           = source.value.guest_os_type
      remote_output_directory = "base/${source.value.remote_output_directory}"
      boot_command            = source.value.boot_cmd

      http_content = {
        "/preseed" = templatefile(source.value.ks, { efi = var.efi })
      }
    }
  }

  provisioner "shell" {
    env = {
      VM_NAME = source.name
    }
    script = "./files/wait.sh"
  }
}
