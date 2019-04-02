provider "libvirt" {
  uri = "${var.qemu_uri}"
}

module "base" {
  source  = "./modules/base"

  # Must have parameters below
  # image: "/vmdisk/jenkins-cluster/test-dummy-for-terraform/sles12sp1-node1.qcow2"
  image   = "${var.image}"
  # pool: "default": "/var/lib/libvirt/images"
  pool    = "${var.storage_pool}"

  # Recommend parameters below
  shared_img = "${var.shared_img}"
  netmode = "${var.netmode}"
  iprange = "${var.iprange}"

  # Optional parameters below
  prefix   = "${var.name_prefix}${terraform.workspace == "default" ? "" : terraform.workspace}"
  netname  = "${var.netname}${terraform.workspace == "default" ? "" : terraform.workspace}"

  # Not used parameters
  timezone = "${var.timezone}"
}

module "host" {
   source             = "./modules/host"
   base_configuration = "${module.base.configuration}"

   name    = "${var.hostname}${terraform.workspace == "default" ? "" : terraform.workspace}"
   count   = "${var.count}"
   drbd_disk_count = "${var.drbd_disk_count}"
   drbd_disk_size  = "${var.drbd_disk_size}"
   host_ips        = "${var.host_ips}"
}

output "iplist" {
  value = "${var.host_ips}"
}
