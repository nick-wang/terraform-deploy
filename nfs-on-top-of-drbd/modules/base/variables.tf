variable "qemu_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "prefix" {
  description = "a prefix for all names of objects to avoid collisions."
  default     = "basetest"
}

variable "pool" {
  description = "libvirt storage pool name for VM disks. default: /var/lib/libvirt/images"
  default     = "default"
}

variable "format" {
  description = "qemu image format"
  default     = "qcow2"
}

variable "image" {
  description = "Path to the image. FIXME."
  default     = "/vmdisk/jenkins-cluster/test-dummy-for-terraform/sles12sp1-node1.qcow2"
}

variable "shared_img" {
  description = "use true to avoid deploying images, mirrors and other shared infrastructure resources"
  default     = false
}

variable "netname" {
  description = "Network name of libvirt. Not support empty for bridge. FIXME."
  default     = ""
}

variable "netmode" {
  description = "Network mode of libvirt. One of none, nat, route, bridge."
  default     = "nat"
}

variable "netdomain" {
  description = "Hostname's domain"
  default     = "me.local"
}

variable "iprange" {
  description = "Used host ip addresses range"
  type        = "list"
  // default     = ["192.168.10.0/24", "192.168.20.0/24"]
  default     = ["192.168.10.0/24"]
}

variable "dhcp" {
  description = "Whether use of network."
  type        = "string"
  default     = true
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Asia/Beijing"
}
