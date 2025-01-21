packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "Protofy"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/noble/ubuntu-24.04.1-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
}

source "virtualbox-iso" "ubuntu24" {
  iso_url        = var.iso_url
  iso_checksum   = var.iso_checksum
  vm_name        = var.vm_name
  guest_os_type  = "Ubuntu_64"
  cpus           = 2
  memory         = 4096
  disk_size      = 20480
  headless       = true
  boot_wait      = "5s"

  http_directory = "http"
  boot_command = [
    # Drop into the grub console or edit the menu entry (depending on the ISO)
    "c<wait>",

    # Set root if needed (some ISOs do this automatically)
    # "set root=(cd0)<enter><wait>",

    # The essential "linux" command:
    "linux /casper/vmlinuz ",
    "boot=casper ",                 # Tells the initrd to load from the ISO's casper filesystem
    "ip=dhcp ",                     # If needed for networking
    "autoinstall ",                # Subiquity: run automated install
    "ds=nocloud-net ",             # Use NoCloud over network
    "cloud-config-url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoinstall.yaml ",
    "--- <enter><wait>",           # The '---' often signals end of kernel params

    # The initrd
    "initrd /casper/initrd<enter><wait>",

    # Finally, boot
    "boot<enter>"
  ]


  communicator = "ssh"
  ssh_username = "protofy"
  ssh_password = "protofy"
  ssh_timeout  = "10m"
}


build {
  name    = "Protofy"
  sources = ["source.virtualbox-iso.ubuntu24"]

  provisioner "shell" {
    script = "scripts/install.sh"
  }
}

