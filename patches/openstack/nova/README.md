# OpenStack Nova Security Patches

This directory contains security patches for OpenStack Nova that need to be applied to the docker-nova image.

## CVE-2024-40767.patch

**Source:** https://review.opendev.org/c/openstack/nova/+/977103  
**Bug:** #2137507  
**CVE:** CVE-2024-40767  

### Description

This patch fixes a security vulnerability where `qemu-img resize` was called without properly constraining the image format. This could allow an authenticated user with a malicious disk image to trick the system into interpreting it as a different format (e.g., QCOW2 with backing files or VMDK with descriptors), potentially leading to unauthorized file access on the host.

### Changes

The patch modifies `nova/virt/disk/api.py` to:
- Always pass the `-f` (format) flag to `qemu-img resize`
- Restrict resizing to only `raw` and `qcow2` formats
- Raise an `InvalidDiskFormat` exception for unsupported formats like VMDK

### Testing

The patch includes comprehensive unit tests in `nova/tests/unit/virt/disk/test_api.py` to verify:
- Proper format specification for raw and qcow2 images
- Rejection of VMDK and other unsupported formats
