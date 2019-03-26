# Usage with workspace:
  terraform workspace new xxx
  terraform workspace select xxx

# bugs:
* In resource.libvirt_network.base_network. "bridge" could be omitted when using "nat" mode. however, will fail to create netcard when count >1. Because all netcards will use the same "bridge" name like "virbr1"
