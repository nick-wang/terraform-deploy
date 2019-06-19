nfs:
  # Global settings:
  mkmnt: False
  mount_opts: noauto,ro
  persist_unmount: True
  persist_mount: False

  # Server settings
  server:
    exports:
      /mnt/mytest: "*(rw,sync,no_subtree_check)"

  # mount settings
  mount:
    somename:
      mountpoint: "/mnt/mytest"
      location: "drbd-node1:/mnt/mytest"
      opts: "vers=3,rsize=65535,wsize=65535"
      persist: True
      mkmnt: True
  unmount:
    someothername:
      mountpoint: "/mnt/mytest"
      location: "drbd-node1:/mnt/mytest"
      persist: False
