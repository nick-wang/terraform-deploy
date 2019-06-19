# Usage with workspace:
  terraform workspace new xxx
  terraform workspace select xxx

# bugs:
* In resource.libvirt_network.base_network. "bridge" could be omitted when using "nat" mode. however, will fail to create netcard when count >1. Because all netcards will use the same "bridge" name like "virbr1"

====================================================
Current steps to configure:
  # Setup nodes
  1. terraform apply
  2. attach.sh on host (terraform)

  # Setup salt
  3. custom.sh on *all* nodes
  4. setup-salt.sh on salt-master node

  # Configure pillar(optional)
  # Maybe disable the install software "install_packages: false"
  # Also need to disable for chrony...
  5. /srv/pillar/xxx   top/drbd/cluster
     /tmp/drbd.j2

  # From here, highstate(need to modify /srv/salt/top.sls)?
  # DRBD salt-formula on salt-master
  6. salt xxx state.apply drbd

  # nfs salt-formula? (Optional since control by pacemaker)

  # cluster salt-formula
  7. salt xxx state.apply cluster

====================================================


Need to disable all repos, due to mirror... disable install pkgs
Need to add a share disk for sbd

Cluster
==========

* cluster.sls
* cluster.sls.simple - without change configuration
* cluster.sls.ori - original from ha-sap-pillar-example
  install_packages: false

* drbd.j2
* drbd.j2.simple - without any para (need to get from pillar and state?)
* performance_optimized.j2 - original template for SAP

  Steps:
    1. cp res template (drbd.j2) to /tmp/drbd.j2 !! on all nodes !!
    2. cp cluster.sls to /srv/pillar/cluster/cluster.sls
    3. cp drbd.sls to /srv/pillar/drbd/formula.sls

  TODO:
    #1. Add vdc disk
    #2. drbd pillar file
    #3. no need nfs formula...
    4. partition in terraform/salt?
    5. use clean image
    6. multiple template

  ISSUE:
    1. the 1st salt '*' state.apply cluster always fail
      maybe modify "join_timer" in cluster pillar file? like 20s
      Since in crmsh cluster init, 1st start hawk before cluster starting
      5s may not enough... especially pacemaker start slow.


TODO:
  cp cluster.sls/drbd.j2 to image, modify the top.sls of pillar
  FIXME: salt '*' state.apply cluster need to run twice... 1st will fail
