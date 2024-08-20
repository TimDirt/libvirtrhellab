variable "vm_name" {
  description = "Number of EC2 instances to deploy"
  type        = string
}

variable "vcpu" {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable "memory" {
  description = "Type of EC2 instance to use"
  type        = string
}

variable "ip_addresses" {
    description = "ip adress of the VM"
    type        = list(string)
}

variable "template_path" {
    description = "template path"
    type        = string
    default     = ""
}

variable "pool" {
    description = "Pool Name"
    type        = string
}

variable "network_id" {
    description = "network resource id"
    type = string
}

variable "filesystems" {
  description = "map of shared filesystems"
  type = map(any)
}

variable "users" {
  description = "List of users to create"
  type = list(object({
    name = string
    uid = optional(number)
    gecos = optional(string)
    groups = optional(string)
    sudo = optional(list(string))
    ssh_authorized_keys = optional(list(string))
  }))
  default = [ 
    {
      name = "student"
      gecos = "student"
      groups = "users,wheel"
      sudo = ["ALL=(ALL) NOPASSWD:ALL"]
    }
  ]
}