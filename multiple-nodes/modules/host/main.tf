provider "libvirt" {
  uri = "${var.qemu_uri}"
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


resource "libvirt_domain" "domain" {
  name       = "${var.base_configuration["prefix"]}-${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}"
  memory     = "${var.memory}"
  vcpu       = "${var.vcpu}"
  running    = "${var.running}"
  count      = "${var.count}"
  qemu_agent = true

  # FIXME, need to calc the count of drbd_disks to support var.drbd_disk_count > 1
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

#  network_interface {
#    network_id = "${libvirt_network.my_network.id}"
#    hostname = "demo2"
#    addresses = ["192.168.80.102"]
#    mac = "AA:BB:DD:11:22:33"
#    wait_for_lease = true
#  }
}
