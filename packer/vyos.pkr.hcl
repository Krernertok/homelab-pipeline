packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "vyos" {
  proxmox_url = "https://192.168.100.100:8006/api2/json"
  username = "${var.pve_username}"
  token = "${var.pve_token}"
  node = "pve1"

  template_name = "vyos-${formatdate("YYYY-MM-DD", timestamp())}"
  template_description = "VyOS template using rolling release ISO"
  onboot = true

# qemu_agent = true

  iso_file = "local:iso/vyos-rolling-latest.iso"
  insecure_skip_tls_verify = true
  vm_name = "vyos-${formatdate("YYYY-MM-DD", timestamp())}"
  vm_id = 101

  memory = 512
  cores = 1
  cpu_type = "host"
  os = "l26"

  network_adapters {
    bridge = "vmbr0"
    model = "virtio"
    mac_address = "repeatable"
  }

  network_adapters {
    bridge = "vmbr1"
    model = "virtio"
    mac_address = "repeatable"
    vlan_tag = 10
  }

  disks {
    storage_pool = "local-lvm"
    type = "scsi"
    disk_size = "5G"
  }

  ssh_host = "${var.vyos_ip_address}"
  ssh_username = "vyos"
  ssh_password = "${var.vyos_password}"

  boot_wait = "40s"
  boot_command = [
    "vyos<enter>",
    "<wait>vyos<enter>",
    "<wait>install image<enter>",
    "<wait><enter>",
    "<wait><enter>",
    "<wait><enter>",
    "<wait>Yes<enter>",
    "<wait><enter>",
    "<wait10><enter>",
    "<wait10><enter>",
    "<wait>${var.vyos_password}<enter>",
    "<wait>${var.vyos_password}<enter>",
    "<wait><enter>",
    "<wait10>reboot<enter>",
    "<wait>y<enter>",
    "<wait45s>vyos<enter>",
    "<wait>${var.vyos_password}<enter>",
    "<wait>configure<enter>",
    "<wait>set service ssh port 22<enter>",
    "<wait>set interfaces ethernet eth0 address ${var.vyos_ip_address}${var.vyos_cidr}<enter>",
    "<wait>commit<enter>",
    "<wait>save<enter>",
    "<wait>exit<enter>",
  ]
}

build {
  sources = ["source.proxmox-iso.vyos"]
}
