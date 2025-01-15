packer {
  required_plugins {
    # Ensure the virtualbox plugin is available. The exact plugin name may vary with your Packer version.
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "ubuntu-24-04-node"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/noble/ubuntu-24.04.1-live-server-amd64.iso"
  # or daily build URL if 24.04 is not released yet
}

variable "iso_checksum" {
  type    = string
  # You can embed the checksum type here with the prefix (e.g., "sha256:...").
  default = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
}

source "virtualbox-iso" "ubuntu24" {
  vm_name          = var.vm_name
  guest_os_type    = "Ubuntu_64"
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  cpus             = 2
  memory           = 4096
  disk_size        = 20480
  headless         = true
  boot_wait        = "5s"

  # Example Subiquity (autoinstall) boot command for Ubuntu Server:
  boot_command = [
    "<esc><esc><enter><wait>",
    "/install/vmlinuz ",
    "auto-install/enable=true ",
    "debconf/frontend=noninteractive ",
    "initrd=/install/initrd ",
    "console-setup/ask_detect=false ",
    "keyboard-configuration/layoutcode=us ",
    "locale=en_US ",
    "keyboard-configuration/modelcode=pc105 ",
    "early-commands=\"echo protofy:protofy | chpasswd\" ",
    " -- <enter>"
  ]

  communicator = "ssh"
  ssh_username = "protofy"
  ssh_password = "protofy"
  ssh_timeout  = "10m"
}

build {
  name    = "ubuntu24-node"
  sources = ["source.virtualbox-iso.ubuntu24"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y curl",
      # Install NodeJS using NodeSource script (adjust the version if needed):
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "node -v",
      "npm -v"
    ]
  }
}

