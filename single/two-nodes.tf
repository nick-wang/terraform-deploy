provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "local1-qcow2" {
  name   = "sles12sp1-node1.qcow2"
  pool   = "default"
  format = "qcow2"
  source = "/vmdisk/jenkins-cluster/test-dummy-for-terraform/sles12sp1-node1.qcow2"
}

resource "libvirt_volume" "local2-qcow2" {
  name   = "sles12sp1-node2.qcow2"
  pool     = "default"
  format   = "qcow2"
  source = "/vmdisk/jenkins-cluster/test-dummy-for-terraform/sles12sp1-node1.qcow2"
}

resource "libvirt_network" "my_network" {
  name      = "demo-nat1"
  mode      = "nat"
  domain    = "mydemo.local"
  addresses = ["192.168.80.0/24"]

  dhcp {
    enabled = true
  }

  autostart = true
}

resource "libvirt_domain" "local1-domain" {
  name   = "demo1"
  memory = "2048"
  vcpu   = 2

  disk {
    volume_id = "${libvirt_volume.local1-qcow2.id}"
  }

  network_interface {
    network_id = "${libvirt_network.my_network.id}"
    hostname = "demo1"
    addresses = ["192.168.80.101"]
    mac = "AA:BB:CC:11:22:22"
    wait_for_lease = true
  }
}

resource "libvirt_domain" "local2-domain" {
  name     = "demo2"
  memory   = "2048"
  vcpu     = 2

  disk {
    volume_id = "${libvirt_volume.local2-qcow2.id}"
  }

  network_interface {
    network_id = "${libvirt_network.my_network.id}"
    hostname = "demo2"
    addresses = ["192.168.80.102"]
    mac = "AA:BB:DD:11:22:33"
    wait_for_lease = true
  }
}
