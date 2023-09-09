source "vmware-iso" "base" {
  cpus      = 1
  memory    = 2048
  cores     = 2
  version   = 19
  disk_size = 5000


  remote_host         = "${var.esxi_host}"
  insecure_connection = var.esxi_insecure
  remote_username     = "${var.esxi_user}"
  remote_password     = "${var.esxi_password}"
  remote_type         = "esx5"
  remote_port         = 22
  remote_datastore    = "${var.datastore}"

  shutdown_command = "sudo -E sh -c 'userdel -rf packer; rm /etc/sudoers.d/90-cloud-init-users; rm /etc/sudoers.d/packer; /sbin/shutdown -hP now'"
  ssh_username     = "packer"
  ssh_password     = "packer"
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
      iso_url                 = source.value.iso_url
      iso_checksum            = source.value.iso_checksum
      guest_os_type           = source.value.guest_os_type
      remote_output_directory = "images/${source.value.remote_output_directory}"
      boot_command            = source.value.boot_cmd
      http_content = {
        "/preseed" = file(source.value.ks)
      }
    }
  }

  provisioner "file" {
    source = "./files/cloudinit.yml"
    destination = "/tmp/99-vmware-guest-customization.cfg"
  }

  provisioner "shell" {
    execute_command = local.run_as_root
    script = "./files/enable-cloudinit.sh"
  }
}
