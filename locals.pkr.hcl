locals {
  debian_bios_cmd = [
    "<wait><wait><wait><esc><wait><wait><wait>",
    "/install.amd/vmlinuz ",
    "initrd=/install.amd/initrd.gz ",
    "auto=true quiet nointeract ",
    "preseed/url=http://${var.http_host}:{{ .HTTPPort }}/preseed ",
    "debconf/frontend=text ",
    "vga=788 ",
    "priority=critical ",
    "hostname={{ .Name }} ",
    "domain=pkr.hcl ",
    "interface=auto ",
    "grub-installer/bootdev=/dev/sda<enter>"
  ]

  debian_uefi_cmd = [
    "<wait><wait><wait>c<wait><wait><wait>",
    "linux /install.amd/vmlinuz ",
    "auto=true ",
    "url=http://${var.http_host}:{{ .HTTPPort }}/preseed ",
    "hostname={{ .Name }} ",
    "domain=pkr.hcl ",
    "interface=auto ",
    "vga=788 noprompt quiet --<enter>",
    "initrd /install.amd/initrd.gz<enter>",
    "boot<enter>"
  ]

  builds = {
    debian12-64 = {
      iso_url                 = "https://mirror.accum.se/debian-cd/current/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso"
      iso_checksum            = "sha256:9f181ae12b25840a508786b1756c6352a0e58484998669288c4eec2ab16b8559"
      guest_os_type           = "debian11-64"
      remote_output_directory = "debian12${var.efi ? "-efi" : ""}"
      ks                      = "files/debconf"
      boot_cmd                = var.efi ? local.debian_uefi_cmd : local.debian_bios_cmd
    },
    debian11-64 = {
      iso_url                 = "http://img.cs.montana.edu/linux/debian/11/amd/debian-11.0.0-amd64-netinst.iso"
      iso_checksum            = "sha512:5f6aed67b159d7ccc1a90df33cc8a314aa278728a6f50707ebf10c02e46664e383ca5fa19163b0a1c6a4cb77a39587881584b00b45f512b4a470f1138eaa1801"
      guest_os_type           = "debian11-64"
      remote_output_directory = "debian11"
      ks                      = "files/debconf"
      boot_cmd = [
        "<wait><wait><wait><esc><wait><wait><wait>",
        "/install.amd/vmlinuz ",
        "initrd=/install.amd/initrd.gz ",
        "auto=true quiet nointeract ",
        "preseed/url=http://${var.http_host}:{{ .HTTPPort }}/preseed ",
        "debconf/frontend=text ",
        "vga=788 ",
        "priority=critical ",
        "hostname={{ .Name }} ",
        "domain=pkr.hcl ",
        "interface=auto ",
        "grub-installer/bootdev=/dev/sda<enter>"
      ]
    }
    "rockylinux9-64" = {
      guest_os_type = "rhel9-64"
      iso_url       = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.2-x86_64-boot.iso"
      iso_checksum  = "11e42da96a7b336de04e60d05e54a22999c4d7f3e92c19ebf31f9c71298f5b42"
      boot_cmd = [
        "<wait><up><tab>linux inst.ks=http://${var.http_host}:{{ .HTTPPort }}/preseed<enter>"
      ]
      ks                      = "files/rockylinux9"
      remote_output_directory = "rocky9"
    }
  }
  run_as_root = "{{.Vars}} sudo -E sh -eux '{{.Path}}'"
}
