variable "servers" {
  description = "Map of project names to configuration."
  type        = map(any)

  default = {
    workstation = {
      vcpu  = 4,
      memory = 4096,
      ip_addresses = ["172.25.250.9"],
      filesystems = {
        workingdir = {
          source = "/home/user/datadir"
          target = "workingdir"
          readonly = false
          accessmode = "passthrough"
        }
      },
    },
    servera = {
      vcpu  = 1,
      memory = 1024,
      ip_addresses = ["172.25.250.10"],
      filesystems = {}
    },
    serverb = {
      vcpu  = 1,
      memory = 1024,
      ip_addresses = ["172.25.250.11"],
      filesystems = {}
    },
    serverc = {
      vcpu  = 1,
      memory = 1024,
      ip_addresses = ["172.25.250.12"],
      filesystems = {}
    },
    serverc = {
      vcpu  = 1,
      memory = 1024,
      ip_addresses = ["172.25.250.13"],
      filesystems = {}
    }
  }
}

variable "users" {
  default = [
    {
      name = "student"
      uid = 1000
      gecos = "student"
      groups = "users,wheel"
      sudo = ["ALL=(ALL) NOPASSWD:ALL"]
      ssh_authorized_keys = [
        "ssh-rsa <ssh pub key here>"
      ]
    }
  ]
}