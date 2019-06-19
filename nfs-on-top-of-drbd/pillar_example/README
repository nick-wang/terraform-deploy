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
    #1. Add vdc disk for sbd 
    #2. drbd pillar file
    #3. no need nfs formula...

  ISSUE:
    #1. the 1st salt '*' state.apply cluster always fail
      maybe modify "join_timer" in cluster pillar file? like 20s
      Since in crmsh cluster init, 1st start hawk before cluster starting
      5s may not enough... especially pacemaker start slow.


TODO:
  cp cluster.sls/drbd.j2 to image, modify the top.sls of pillar
