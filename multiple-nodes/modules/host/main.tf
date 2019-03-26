provider "libvirt" {
  uri = "${var.qemu_uri}"
}

locals {
  network_card_list = "${split(",", "${var.base_configuration["network_id"]}")}"
  network_iprange   = "${split(",", "${var.base_configuration["iprange"]}")}"
  // FIXME, addresses should get from iprange
  network_addresses = ["192.168.10.10"]
}

resource "libvirt_volume" "main_disk" {
  name             = "${var.base_configuration["prefix"]}-${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}-maindisk"
  base_volume_name = "${var.base_configuration["shared_img"] ? "" : var.base_configuration["prefix"]}-baseimage"
  pool             = "${var.base_configuration["pool"]}"
  count            = "${var.count}"
}

resource "libvirt_volume" "drbd_disk" {
  name  = "${var.base_configuration["prefix"]}-${var.name}${var.count * var.drbd_disk_count > 1 ? "-${count.index  + 1}" : ""}-drbddisk"
  pool  = "${var.base_configuration["pool"]}"
  count = "${var.count * var.drbd_disk_count}"
  size  = "${var.drbd_disk_size}"
}

// https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/domain.html.markdown
resource "libvirt_domain" "domain" {
  name       = "${var.base_configuration["prefix"]}-${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}"
  memory     = "${var.memory}"
  vcpu       = "${var.vcpu}"
  running    = "${var.running}"
  count      = "${var.count}"
  qemu_agent = true

  # FIXME, need to calc the count of drbd_disks to support flexible var.drbd_disk_count
  # May use %{ if xxx } %{ else } %{ endif } or
  #         %{ for xxx } %{ endfor }
  # https://www.terraform.io/docs/configuration/expressions.html
  disk = ["${concat(
    list(
      map("volume_id", "${element(libvirt_volume.main_disk.*.id, count.index)}"),
      map("volume_id", "${element(libvirt_volume.drbd_disk.*.id, count.index)}"),
    ),
    var.additional_disk
  )}"]

  network_interface = ["${list(
    merge(
      map(
        "network_id", "${local.network_card_list[0]}",
        "hostname",   "node${count.index + 1}",
        "mac",        "AA:BB:CC:11:11:3${count.index + 1}",
        "wait_for_lease", true,
      ),
      map(
        "addresses",  "${list("${local.network_addresses[0]}${count.index+1}")}",
      )
    ))}"]

# Remove the support of two netcard
#  network_interface = ["${list(
#    merge(
#      map(
#        "network_id", "${local.network_card_list[0]}",
#        "hostname",   "node${count.index + 1}",
#        "mac",        "AA:BB:CC:11:11:3${count.index + 1}",
#        "wait_for_lease", true,
#      ),
#      map(
#        "addresses",  "${list("${local.network_addresses[0]}${count.index+1}")}",
#      )
#    ),
#    merge(
#      map(
#        "network_id", "${local.network_card_list[1]}",
#        "mac",        "AA:BB:DD:11:22:3${count.index + 1}",
#        "wait_for_lease", true,
#      ),
#      map(
#        "addresses",  "${list("${local.network_addresses[1]}${count.index+1}")}",
#      )
#    ),
#  )}"]
#  
}
