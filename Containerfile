### Based off the almalinux-bootc template

FROM docker.io/rockylinux/rockylinux:10.1 as repos
FROM quay.io/centos-bootc/centos-bootc:stream10 as imagectl
FROM quay.io/centos-bootc/centos-bootc:stream10 as builder

RUN dnf install -y \
    podman \
    bootc \
    ostree \
    rpm-ostree \
    && dnf clean all

COPY --from=imagectl /usr/share/doc/bootc-base-imagectl/ /usr/share/doc/bootc-base-imagectl/
COPY --from=imagectl /usr/libexec/bootc-base-imagectl /usr/libexec/bootc-base-imagectl
RUN chmod +x /usr/libexec/bootc-base-imagectl

RUN rm -rf /etc/yum.repos.d/*

# Using locally provided `trilliumos.repo` due to an error with the Rocky Linux
# mirrorlist URL. The local repo file uses "baseurl" and the public repository 
# from the University of Calgary, and includes the COPR repo hosting the kernel
# and other packages required for building the trillium-seed base image.

# COPY --from=repos /etc/yum.repos.d/*.repo /etc/yum.repos.d/
COPY trilliumos.repo /etc/yum.repos.d/
COPY --from=repos /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10 /etc/pki/rpm-gpg

COPY trillium-seed.yaml /usr/share/doc/bootc-base-imagectl/manifests/
RUN /usr/libexec/bootc-base-imagectl build-rootfs --reinject --manifest=trillium-seed /target-rootfs

###

FROM scratch

COPY --from=builder /target-rootfs/ /

LABEL containers.bootc 1
LABEL ostree.bootable 1
LABEL org.opencontainers.image.vendor trilliumOS
LABEL org.opencontainers.image.description trillium-seed Bootable Container Image built from Rocky Linux
RUN bootc container lint --fatal-warnings
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]