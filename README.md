# Write before:
  This is still in bleedy edge, not even in alpha release.

# Purpose:
  Quick deploy a cluster for salt-drbd development and deploy.

# Version:
  0.1

# Usage with workspace:
  terraform workspace new xxx
  terraform workspace select xxx

# Known issues:
  Revisit after alpha.

# External issues:
* In resource.libvirt_network.base_network. "bridge" could be omitted when using "nat" mode. however, will fail to create netcard when count >1. Because all netcards will use the same "bridge" name like "virbr1"
