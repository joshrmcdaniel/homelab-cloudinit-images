locals {
  builds = {
    debian12-64 = {
      iso_url                 = "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.1.0-amd64-DVD-1.iso"
      iso_checksum            = "sha256:9168ff53d789537db4f5233e7dfa5e860519c44b68132b70805218f842b00041"
      guest_os_type           = "debian11-64"
      remote_output_directory = "debian12"
      ks                      = "files/debconf"
      boot_cmd = [
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
  }
}