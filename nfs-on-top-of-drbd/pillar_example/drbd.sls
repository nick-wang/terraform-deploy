# -*- mode: yaml -*-
# vim: ft=yaml

drbd:
  ## Install required package to manage DRBD
  install_packages: false

  ## Install required package to configure DRBD in pacemaker cluster
  #with_ha: false

  ## Perform initial sync for DRBD resources
  #need_init_sync: true

  ## Optional: stop the DRBD resources after initial resync
  #stop_after_init_sync: true

  ## Optional: format the DRBD resource after initial resync
  #need_format: true


  # Salt deployment/manage related parameters
  salt:
    # Pirmary node when promoting DRBD
    # TODO: Only support single primary currently
    promotion: "drbd-node1"
  #  # Resource template for /etc/drbd.d/xxx.res
  #  res_template: "res_single_vol_v9.j2"
  #  # Optional: interval check time for waiting for resource synced
  #  sync_interval: 10
  #  # Optional: timeout for waiting for resource synced
  #  sync_timeout: 500


  ## Configures some "global" parameters of /etc/drbd.d/global_common.conf
  #global:
  #  # Optional: Participate in DRBD's online usage counter
  #  usage_count: "no"
  #  # Optional: A sizing hint for DRBD to right-size various memory pools.
  #  minor_count: 9
  #  # Optional: The user dialog redraws the second count every time seconds
  #  dialog_refresh: 1


  ## Configures some "common" parameters of /etc/drbd.d/global_common.conf
  #common:
  #  # This section is used to fine tune the behaviour of the resource object
  #  options:
  #    # Optional: Cluster partition requires quorum to modify the replicated data set.
  #    quorum: "off"

  #  # This section is used to fine tune DRBD's properties.
  #  net:
  #    # Optional: you may assign the primary role to both nodes.
  #    multi_primaries: "no"
  #    # Optional: preventive measures to avoid situations where both nodes are primary and disconnected(AKA split brain)
  #    fencing: "resource-and-stonith"
  #    # Optional: split brain handler when no primary
  #    after_sb_0pri: "discard-zero-changes"
  #    # Optional: split brain handler when one primary
  #    after_sb_1pri: "discard-secondary"
  #    # Optional: split brain handler when two primaries
  #    after_sb_2pri: "disconnect"

  #  # Define handlers (executables) that are started by the DRBD system in response to certain events.
  #  handlers:
  #    # Optional: This handler is called in case the node needs to fence the peer's disk
  #    fence_peer: "/usr/lib/drbd/crm-fence-peer.9.sh"
  #    # Optional: This handler is called in case the node needs to unfence the peer's disk
  #    unfence_peer: "/usr/lib/drbd/crm-unfence-peer.9.sh"
  #    # Optional: This handler is called before a resync begins on the node that becomes resync target.
  #    before_resync_target: "/usr/lib/drbd/snapshot-resync-target-lvm.sh -p 15 -- -c 16k"
  #    # Optional: This handler is called after a resync operation finished on the node.
  #    after_resync_target: "/usr/lib/drbd/unsnapshot-resync-target-lvm.sh"
  #    # Optional: DRBD detected a split brain situation but remains unresolved. This handler should alert someone.
  #    split_brain: "/usr/lib/drbd/notify-split-brain.sh root"


  resource:
    - name: "beijing"
      device: "/dev/drbd5"
      disk: "/dev/vdb1"

      # Refer to bsc#1101037
      fixed_rate:  true
      c_plan_ahead: 20
      c_max_rate: "100M"
      c_fill_target: "10M"

      # Salt specific
      file_system: "xfs"
      mount_point: "/mnt/fs-A"
      virtual_ip: "192.168.10.201"

      nodes:
        - name: "drbd-node1"
          ip: "192.168.10.101"
          port: 7990
          id: 1
        - name: "drbd-node2"
          ip: "192.168.10.102"
          port: 7990
          id: 2

    - name: "shanghai"
      device: "/dev/drbd6"
      disk: "/dev/vdb2"
      on_io_error: "detach"

      fixed_rate:  True
      resync_rate: "150M"

      # Salt specific
      file_system: "ext4"
      mount_point: "/mnt/fs-B"
      virtual_ip: "192.168.10.202"

      nodes:
        - name: "drbd-node1"
          ip: "192.168.10.101"
          port: 7982
          id: 1
        - name: "drbd-node2"
          ip: "192.168.10.102"
          port: 7982
          id: 2
