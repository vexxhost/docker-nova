# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-12-17T01:27:44Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2023.1@sha256:a6b76c74ee688a9de612c2f6c4bde16349d3f1df3a2682bcfdff173c2be8d5c9 AS build
RUN --mount=type=bind,from=nova,source=/,target=/src/nova,readwrite \
    --mount=type=bind,from=nova-scheduler-filters,source=/,target=/src/nova-scheduler-filters,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/nova \
        /src/nova-scheduler-filters \
        python-ironicclient \
        storpool \
        storpool.spopenstack
EOF
ADD --chmod=644 \
    https://github.com/storpool/storpool-openstack-integration/raw/master/drivers/os_brick/openstack/caracal/storpool.py \
    /var/lib/openstack/lib/python3.10/site-packages/os_brick/initiator/connectors/storpool.py

FROM ghcr.io/vexxhost/python-base:2023.1@sha256:136d90a4fb41be5584c2c3a6bddc6738d7d850e01988b109dbd68a3b1ec9999c
RUN \
    groupadd -g 42424 nova && \
    useradd -u 42424 -g 42424 -M -d /var/lib/nova -s /usr/sbin/nologin -c "Nova User" nova && \
    mkdir -p /etc/nova /var/log/nova /var/lib/nova /var/cache/nova && \
    chown -Rv nova:nova /etc/nova /var/log/nova /var/lib/nova /var/cache/nova
ADD https://github.com/novnc/noVNC.git#v1.4.0 /usr/share/novnc
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    ceph-common dmidecode genisoimage iproute2 libosinfo-bin lsscsi ndctl nfs-common nvme-cli openssh-client ovmf python3-libvirt python3-rados python3-rbd qemu-efi-aarch64 qemu-block-extra qemu-utils sysfsutils udev util-linux swtpm swtpm-tools libtpms0
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
COPY --from=build --link /var/lib/openstack /var/lib/openstack
