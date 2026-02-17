# OpenStack Nova Patches

This directory contains backport patches for OpenStack Nova that are applied during the Docker image build process.

## Patches

### CVE-disk-extend-format.patch

**Source**: https://review.opendev.org/c/openstack/nova/+/977100  
**Bug**: https://bugs.launchpad.net/nova/+bug/2137507  
**Description**: Security fix for disk.extend() to pass format to qemu-img

This patch addresses a security vulnerability where Nova passes disk images to qemu-img for resize operations without constraining the format. An instance with a previously-raw disk image being used by imagebackend.Flat is susceptible to the user writing a qcow2 (or other) header to their disk, causing the unconstrained qemu-img resize operation to interpret it as a qcow2 file.

The fix ensures that:
- Only raw or qcow2 formats are supported for disk resize operations
- The format is explicitly passed to qemu-img using the `-f` flag
- Invalid formats raise an `InvalidDiskFormat` exception

**Status**: Merged upstream, backported for use in docker-nova builds
