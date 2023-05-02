packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "debian-small" {
  proxmox_url = "https://${var.pve_host_ip}:8006/api2/json"
  username = "${var.pve_username}"
  token = "${var.pve_token}"
  node = "pve1"

  template_name = "debian-11-small"
  template_description = "Debian 11.6 - bullseye"
  onboot = true

  qemu_agent = true
  cloud_init = true
  cloud_init_storage_pool = "local-lvm"

  iso_file = "local:iso/debian-11.6.0-amd64-netinst.iso"
  insecure_skip_tls_verify = true
  vm_name = "debian-small"
  vm_id = 102

  memory = 1024
  cores = 1
  cpu_type = "host"
  os = "l26"

  network_adapters {
    bridge = "vmbr0"
    model = "virtio"
    mac_address = "repeatable"
  }

  disks {
    storage_pool = "local-lvm"
    type = "scsi"
    disk_size = "20G"
  }

  ssh_username = "root"
  ssh_password = "${var.root_password}"
  ssh_timeout = "30m"

  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "/install.amd/vmlinuz<wait>",
    " initrd=/install.amd/initrd.gz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
    " -- <wait>",
    "<enter><wait>"
  ]

  http_content = {
    "/preseed.cfg" = templatefile("preseed.cfg.pkrtpl.hcl", { var = var })
  }
}

build {
  sources = ["source.proxmox-iso.debian-small"]

  provisioner "shell" {
    inline = [
      "echo set debconf to Noninteractive",
      "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections",
      "apt-get update",
      "apt-get -y upgrade",
      "apt-get -y install qemu-guest-agent cloud-init",
    ]
  }
}
