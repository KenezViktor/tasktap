# Disk image
variable "disk_image" {
  type = string
  default = "/var/lib/libvirt/images/bookworm-packer"
}

variable "number_of_controllers" {
  type = number
  default = 1
}

variable "number_of_workers" {
  type = number
  default = 2
}

variable "domain_name" {
  type = string
  default = "home.lab"
}

variable "controller_subdomain" {
  type = string
  default = "controller-"
}

variable "worker_subdomain" {
  type = string
  default = "worker-"
}

variable "network" {
    type = object({
    ipv4 = string
    gateway = string
    network = string
    netmask = string
    dns = string
  })
  default = {
    ipv4 = "10.0.40."
    gateway = "10.0.40.1"
    network = "10.0.40.0"
    netmask = "/24"
    dns = "10.0.40.1"
  }
}