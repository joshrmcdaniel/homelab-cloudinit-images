source "vmware-iso" "base" {
  cpus      = 1
  memory    = 2048
  cores     = 2
  version   = 19
  disk_size = 5000


  remote_host      = "${var.esxi_host}"
  remote_username  = "${var.esxi_user}"
  remote_password  = "${var.esxi_password}"
  remote_type      = "esx5"
  remote_port      = 22
  remote_datastore = "${var.datastore}"

  shutdown_command = "echo 'packer' | sudo -S -E sh -c 'userdel -rf packer; rm /etc/sudoers.d/90-cloud-init-users; rm /etc/sudoers.d/packer; /sbin/shutdown -hP now'"
  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "10m"
  network          = "bridge"
  network_name     = "packer"

  vnc_over_websocket  = true
  insecure_connection = true
  skip_export         = true
  skip_compaction     = true
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

  provisioner "shell" {
    execute_command = local.run_as_root
    only            = ["vmware-iso.debian12-64"]
    inline          = ["apt install -y cloud-init"]
  }
  provisioner "shell" {
    execute_command = local.run_as_root
    only            = ["vmware-iso.rockylinux9-64"]
    inline = [
      "dnf install -y cloud-init"
    ]
  }

  provisioner "shell" {
    execute_command = local.run_as_root
    inline = [
      "cloud-init clean",
      "cloud-init clean -l",
      <<-EOC
        cat <<EOF | tee /etc/cloud/cloud.cfg.d/99-vmware-guest-customization.cfg
        disable_vmware_customization: false
          datasource:
            VMware:
              vmware_cust_file_max_wait: 20
        EOF
        EOC
      ,
      "vmware-toolbox-cmd config set deployPkg enable-custom-scripts true",
      "systemctl enable cloud-init-local.service",
      "systemctl enable cloud-init.service",
      "systemctl enable cloud-config.service",
      "systemctl enable cloud-final.service",
    ]
  }
}
