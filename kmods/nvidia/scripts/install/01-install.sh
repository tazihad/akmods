#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

rpm-ostree install /tmp/akmods/rpms/nvidia-addons-*.rpm

# Enable nvidia-container-toolkit repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Install Nvidia drivers
rpm-ostree install \
    libnvidia-fbc \
    libva-nvidia-driver \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-modprobe \
    nvidia-persistenced \
    nvidia-settings \
    nvidia-container-toolkit \
    /tmp/akmods/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm

cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
