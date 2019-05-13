# Change according to the output of ../module/base
base_configuration = {
  prefix = "basetest"
  pool = "default"
  image_source = "/vmdisk/jenkins-cluster/test-dummy-for-terraform/sles12sp1-node1.qcow2"
  image_id = "/var/lib/libvirt/images/basetest-baseimage"
  iprange="192.168.10.0/24,192.168.20.0/24"
  shared_img=0

  # Need to change the network_id after base create, use the real one.
  #network_id = "cdcc2a40-2b05-4afa-b52f-a8ae97ffdb10,d3f4b4cb-4573-4fda-8733-edcc01b1f546"
  network_id = "6207f3cf-3467-4d9d-b235-b258e9c442e7"
}

count=2
