variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type        = "map"
}

variable "qemu_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "name" {
  description = "hostname, without the domain part"
  default     = "testnode"
}

variable "count" {
  description = "Number of hosts like this one"
  default     = 1
}

variable "drbd_disk_count" {
  description = "Number of drbd disk"
  default     = 1
}

variable "drbd_disk_size" {
  description = "drbd partition disk size"
  default     = "1024000000"              # 1GB
}

variable "host_ips" {
  description = "IP addresses to set to the nodes"
  default     = []
}


// Provider-specific variables
variable "memory" {
  description = "RAM memory in MiB"
  default     = 1024
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default     = true
}

variable "additional_disk" {
  description = "disk block definition(s) to be added to this host"
  default     = []
}
