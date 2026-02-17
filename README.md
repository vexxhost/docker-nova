# docker-nova
Docker image for OpenStack Nova

## Security Patches

Security patches for OpenStack Nova are stored in the `patches/openstack/nova/` directory and are automatically applied during the build process via the `vexxhost/docker-atmosphere` checkout action.

### Applied Patches

- `0003-Make-disk.extend-pass-format-to-qemu-img.patch` - Backport patch for CVE-2024-40767 that fixes arbitrary file access vulnerability by ensuring `qemu-img resize` is called with explicit format constraints (from https://review.opendev.org/c/openstack/nova/+/977104)
