# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-12-17T01:27:44Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2026.1@sha256:50749858650925b49af1b3fca8a292d302c0a051282aed99bf02a89588f0b595 AS build
ARG NOVA_VERSION=33.0.2+a8e.10.3
RUN --mount=type=bind,from=nova-scheduler-filters,source=/,target=/src/nova-scheduler-filters,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        "nova==${NOVA_VERSION}" \
        /src/nova-scheduler-filters \
        python-ironicclient \
        storpool \
        storpool.spopenstack
EOF
ADD --chmod=644 \
    https://github.com/storpool/storpool-openstack-integration/raw/master/drivers/os_brick/openstack/caracal/storpool.py \
    /var/lib/openstack/lib/python3.12/site-packages/os_brick/initiator/connectors/storpool.py

FROM ghcr.io/vexxhost/python-base:2026.1@sha256:c38025e038ebb7d0e3360eb0df34d68fcc10e4e5c05dcc2fa42d7c595a3198b2
RUN \
    groupadd -g 42424 nova && \
    useradd -u 42424 -g 42424 -M -d /var/lib/nova -s /usr/sbin/nologin -c "Nova User" nova && \
    mkdir -p /etc/nova /var/log/nova /var/lib/nova /var/cache/nova && \
    chown -Rv nova:nova /etc/nova /var/log/nova /var/lib/nova /var/cache/nova
ADD https://github.com/novnc/noVNC.git#v1.6.0 /usr/share/novnc
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    ceph-common dmidecode genisoimage iproute2 libosinfo-bin lsscsi lvm2 mdevctl ndctl nfs-common nvme-cli openssh-client ovmf python3-libvirt python3-rados python3-rbd qemu-efi-aarch64 qemu-block-extra qemu-utils sysfsutils udev util-linux swtpm swtpm-tools libtpms0
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
COPY --from=build --link /var/lib/openstack /var/lib/openstack
