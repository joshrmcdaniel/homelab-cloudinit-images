source "vmware-iso" "base" {
  cpus         = 1
  memory       = 2048
  cores        = 2
  version      = 19
  disk_size    = var.disk_size * 1000
  disk_type_id = "thin"

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
        "/preseed" = file(source.value.ks)
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
