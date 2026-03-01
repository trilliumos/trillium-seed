# Begin with a standard bootc base image that is reused as a "builder" for the custom image.
FROM quay.io/centos-bootc/centos-bootc:stream10 as builder

COPY trilliumos.repo /etc/yum.repos.d/

# Configure and override source RPM repositories, if necessary. This step is not required when building up from minimal unless referencing specific content views or target mirrored/snapshotted/pinned versions of content.
# Add additional repositories to apply customizations to the image. However, referencing a custom manifest in this step is not currently supported without forking the code.
# Build the root file system by using the specified repositories and non-RPM content from the "builder" base image.
# If no repositories are defined, the default build will be used. You can modify the scope of packages in the base image by changing the manifest between the "standard" and "minimal" sets.
COPY trillium-seed.yaml /usr/share/doc/bootc-base-imagectl/manifests/
RUN dnf repolist && /usr/libexec/bootc-base-imagectl build-rootfs --manifest=trillium-seed /target-rootfs

# Create a new, empty image from scratch.
FROM scratch

# Copy the root file system built in the previous step into this image.
COPY --from=builder /target-rootfs/ /

# Define required labels for this bootc image to be recognized as such.
LABEL containers.bootc 1
LABEL ostree.bootable 1

# Optional labels that only apply when running this image as a container. These keep the default entry point running under systemd.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]

# Run the bootc linter to avoid encountering certain bugs and maintain content quality. Place this command last in your Containerfile.
RUN bootc container lint