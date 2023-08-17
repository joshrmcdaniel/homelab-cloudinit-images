source "vmware-iso" "debian12" {
  iso_url      = "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.1.0-amd64-DVD-1.iso"
  iso_checksum = "sha256:9168ff53d789537db4f5233e7dfa5e860519c44b68132b70805218f842b00041"

  cpus          = 1
  memory        = 2048
  cores         = 2
  version       = 19
  disk_size     = 5000
  guest_os_type = "debian11-64"


  remote_host             = "${var.esxi_host}"
  remote_username         = "${var.esxi_user}"
  remote_password         = "${var.esxi_password}"
  remote_type             = "esx5"
  remote_port             = 22
  remote_datastore        = "${var.datastore}"
  remote_output_directory = "isos"

  shutdown_command = "echo 'packer' | sudo -S -E sh -c 'userdel -rf packer; rm /etc/sudoers.d/90-cloud-init-users; /sbin/shutdown -hP now'"
  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "10m"
  network          = "bridge"
  network_name     = "packer"

  vnc_over_websocket  = true
  insecure_connection = true
  skip_export         = true
  skip_compaction     = true

  http_content = {
    "/preseed" = file("files/debconf")
  }

  boot_command = [
    "<wait><wait><wait><esc><wait><wait><wait>",
    "/install.amd/vmlinuz ",
    "initrd=/install.amd/initrd.gz ",
    "auto=true quiet nointeract ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed ",
    "debconf/frontend=text ",
    "vga=788 ",
    "priority=critical ",
    "hostname={{ .Name }} ",
    "domain=pkr.hcl ",
    "interface=auto ",
    "grub-installer/bootdev=/dev/sda<enter>"
  ]
}

build {
  sources = ["source.vmware-iso.debian12"]

  provisioner "shell" {
    execute_command = "echo 'packer' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline = [
      "apt install -y cloud-init",
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