terraform {
  required_version = "~> 0.11.7"
}

provider "libvirt" {
  uri = "${var.qemu_uri}"
}

locals {
  # Will be override by ${var.netname}
  dummy_net_name = "${var.prefix}-basenet"
}

resource "libvirt_volume" "base_image" {
  name   = "${var.prefix}-baseimage"
  pool   = "${var.pool}"
  format = "${var.format}"
  source = "${var.image}"
  # Will not create a new base image when shared_img is true
  count  = "${var.shared_img ? 0 : 1}"
}

resource "libvirt_network" "base_network" {
  name      = "${var.netname != "" ? var.netname : local.dummy_net_name}${length(var.iprange) > 1 ? "-${count.index + 1}" : ""}"
  mode      = "${var.netmode}"
  domain    = "${var.netdomain}${length(var.iprange) > 1 ? ".${count.index  + 1}" : ""}"
  addresses = ["${element(var.iprange, count.index)}"]
  count     = "${length(var.iprange)}"
  # Startswith "virbr5" or "br5" to avoid conflict
  # Could be empty if "${length(var.iprange)}" is 1
  bridge    = "${var.netmode == "nat" ? "virbr" : "br"}${count.index + 5}"

  dhcp {
    enabled = "${var.dhcp}"
  }

  autostart = true
}

output "configuration" {
  depends_on = [ 
    # The base image and base network must be created before setup a VM
    "libvirt_volume.base_image",
    "libvirt_network.base_network",
  ]

  value = {
    dummy    = "test"
    timezone = "${var.timezone}"
    domain   = "${var.netdomain}"
    prefix   = "${var.prefix}"
    iprange  = "${join(",", var.iprange)}"
    pool     = "${var.pool}"
    # Use join to change possible list to string. Since need have homogenous type
    image_id   = "${join(",", libvirt_volume.base_image.*.id)}"
    image_name   = "${join(",", libvirt_volume.base_image.*.name)}"
    image_source = "${var.image}"
    network_id = "${join(",", libvirt_network.base_network.*.id)}"
    shared_img = "${var.shared_img}"
  }
}
