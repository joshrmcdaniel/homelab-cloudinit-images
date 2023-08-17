source "vmware-iso" "debian" {
  iso_url             = "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.1.0-amd64-DVD-1.iso"
  iso_checksum        = "sha256:9168ff53d789537db4f5233e7dfa5e860519c44b68132b70805218f842b00041"
  remote_host         = "${var.esxi_host}"
  remote_username     = "${var.esxi_user}"
  remote_password     = "${var.esxi_password}"
  shutdown_command    = "sudo su root -c 'userdel -rf packer; rm /etc/sudoers.d/90-cloud-init-users; /sbin/shutdown -hP now'"
  ssh_username        = "packer"
  ssh_password        = "packer"
  vnc_over_websocket  = true
  insecure_connection = true
  remote_type         = "esx5"
  remote_port         = 22
  cpus                = 1
  memory              = 2048
  cores               = 2
  version             = 19
  guest_os_type       = "debian11-64"
  network             = "bridge"
  network_name        = "packer"
  ssh_timeout         = "10m"
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
  sources = ["source.vmware-iso.debian"]

  provisioner "shell" {
    execute_command =  "echo 'packer' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline = [
        "sudo apt update",
        "sudo apt install -y cloud-init",
        "curl -fsSL 'https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh' | sudo bash",
        "sudo cloud-init clean",
        "sudo cloud-init clean -l"
        ]
  }
}