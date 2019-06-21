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
  name             = "${var.base_configuration["prefix"]}-${var.name}${var.hcount > 1 ? "-${count.index  + 1}" : ""}-maindisk"
  base_volume_name = "${var.base_configuration["shared_img"] ? "" : var.base_configuration["prefix"]}-baseimage"
  pool             = "${var.base_configuration["pool"]}"
  count            = "${var.hcount}"
}

resource "libvirt_volume" "drbd_disk" {
  name  = "${var.base_configuration["prefix"]}-${var.name}${var.hcount * var.drbd_disk_count > 1 ? "-${count.index  + 1}" : ""}-drbddisk"
  pool  = "${var.base_configuration["pool"]}"
  count = "${var.hcount * var.drbd_disk_count}"
  size  = "${var.drbd_disk_size}"
}

#https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/volume.html.markdown
resource "libvirt_volume" "sbd_disk" {
  name  = "${var.base_configuration["prefix"]}-${var.name}-sbddisk"
  pool  = "${var.base_configuration["pool"]}"
  count = 1
  size  = "102400000"  # 100M

  #https://www.w3schools.com/xml/xsl_languages.asp
  #https://libvirt.org/formatstorage.html#exampleVol
  xml {
    xslt = "${file("modules/host/volume_raw.xsl")}"
  }
}

// https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/domain.html.markdown
resource "libvirt_domain" "domain" {
  name       = "${var.base_configuration["prefix"]}-${var.name}${var.hcount > 1 ? "-${count.index  + 1}" : ""}"
  memory     = "${var.memory}"
  vcpu       = "${var.vcpu}"
  running    = "${var.running}"
  count      = "${var.hcount}"
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

  disk {
    volume_id = "${element(libvirt_volume.sbd_disk.*.id, 0)}"
  }

  #https://libvirt.org/formatdomain.html
  xml {
    xslt = "${file("modules/host/shareable.xsl")}"
  }

  network_interface = ["${list(
    merge(
      map(
        "network_id", "${local.network_card_list[0]}",
        "hostname",   "node${count.index + 1}",
        "mac",        "AA:BB:CC:11:11:3${count.index + 1}",
        "wait_for_lease", true,
      ),
      map(
        "addresses",  "${list("${local.network_addresses[0]}${count.index}")}",
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
#        "addresses",  "${list("${local.network_addresses[0]}${count.index}")}",
#      )
#    ),
#    merge(
#      map(
#        "network_id", "${local.network_card_list[1]}",
#        "mac",        "AA:BB:DD:11:22:3${count.index + 1}",
#        "wait_for_lease", true,
#      ),
#      map(
#        "addresses",  "${list("${local.network_addresses[1]}${count.index}")}",
#      )
#    ),
#  )}"]
#
}

output "information" {
  depends_on = [
    "libvirt_volume.main_disk",
    "libvirt_volume.drbd_disk",
    "libvirt_domain.domain",
  ]

  value = {
    guestname   = "${join(",", libvirt_domain.domain.*.name)}"
  }
}

output "addresses" {
  // Returning only the addresses is not possible right now. Will be available in terraform 12
  // https://bradcod.es/post/terraform-conditional-outputs-in-modules/
  value = "${libvirt_domain.domain.*.network_interface}"
}

output "diskes" {
  value = "${libvirt_domain.domain.*.disk}"
}
